import 'dart:math';

/// 内部类，用于封装所有缓冲区实例之间共享的数据。
class _ChunkedBufferData {
  /// 共享的字符串块列表。只有 Master 实例可以向其中添加元素。
  final List<String> chunks = [];

  /// 所有块中字符的总长度。由 Master 在写入时更新。
  int totalLength = 0;
}

/// 一个高效的、分块的字符串缓冲区，支持主从（Master/Slave）视图。
///
/// 这个实现允许多个缓冲区实例共享相同的底层数据存储，但维护各自独立的
/// 读取指针。这对于流式解析等场景非常高效，其中一个数据源可以被多个
/// 独立的解析器同时消费而无需复制数据。
///
/// **核心概念:**
/// - **Master (可写实例):** 通过默认构造函数创建的实例。它拥有底层数据
///   存储，并且是唯一可以调用 `write()` 的实例。
/// - **Slave (只读视图):** 通过 Master 的 `clone()` 方法创建的实例。它们
///   共享 Master 的数据，但只能读取和 `pop()` 自己的视图，不能写入。
/// - **独立副本:** 通过 `cleanClone()` 方法可以创建一个全新的、完全独立的
///   Master 实例，它拥有自己数据的副本，可以自由写入。
class ChunkedStringBuffer {
  /// 指向共享数据的引用。
  final _ChunkedBufferData _data;

  /// 标记此实例是否为只读视图 (Slave)。
  final bool isReadOnly;

  /// 指向当前视图的第一个块在 `_data.chunks` 列表中的索引。
  int _startChunkIndex;

  /// 表示在 `_chunks[_startChunkIndex]` 中，当前视图的起始字符偏移量。
  int _startCharOffset;

  /// 从整个数据流的开始，此实例已经“消费”掉的字符总数。
  int _consumedLength;

  /// [NEW] 视图的结束边界。如果为 null，则为动态视图，否则为固定长度的快照。
  final int? _endMasterIndex;

  ChunkedStringBuffer()
    : _data = _ChunkedBufferData(),
      isReadOnly = false,
      _startChunkIndex = 0,
      _startCharOffset = 0,
      _consumedLength = 0,
      _endMasterIndex = null; // Master 是一个动态视图

  /// 内部构造函数，用于创建共享数据的实例 (Slaves)。
  ChunkedStringBuffer._internal(
    this._data, {
    required this.isReadOnly,
    required int startChunkIndex,
    required int startCharOffset,
    required int consumedLength,
    required int? endMasterIndex, // 构造函数现在接受 endMasterIndex
  }) : _startChunkIndex = startChunkIndex,
       _startCharOffset = startCharOffset,
       _consumedLength = consumedLength,
       _endMasterIndex = endMasterIndex;

  /// 对于快照，长度是固定的。对于动态视图，长度会随 Master 写入而改变。
  int get length {
    final end = _endMasterIndex ?? _data.totalLength;
    return max(0, end - _consumedLength);
  }

  /// 检查当前视图是否为空。
  bool get isEmpty => length == 0;

  /// 将当前视图的局部索引转换为全局唯一的“主索引”。
  ///
  /// 主索引是相对于整个共享数据流的绝对位置，不受任何 `pop` 操作影响。
  /// 这是一个 O(1) 操作。
  ///
  /// [localIndex] 必须是当前视图内的有效索引。
  int toMasterIndex(int localIndex) {
    if (localIndex < 0 || localIndex > length) {
      // 注意改为允许等于 length
      throw RangeError.range(localIndex, 0, length, 'localIndex');
    }
    return _consumedLength + localIndex;
  }

  /// 将全局唯一的“主索引”转换为当前视图的局部索引。
  ///
  /// 如果主索引不在当前视图的可见范围内（例如，已经被 pop 掉），
  /// 此方法会抛出 [RangeError]。
  /// 这是一个 O(1) 操作。
  int fromMasterIndex(int masterIndex) {
    final end = _endMasterIndex ?? _data.totalLength;
    if (masterIndex < _consumedLength || masterIndex > end) {
      throw RangeError.value(
        masterIndex,
        'masterIndex',
        'Master index is outside the visible range of this buffer view.',
      );
    }
    return masterIndex - _consumedLength;
  }

  /// 在缓冲区的末尾追加一个字符串。
  ///
  /// **注意:** 只有 Master (可写) 实例才能调用此方法。
  /// 在只读视图 (Slave) 上调用会抛出 [StateError]。
  void write(String str) {
    if (isReadOnly) {
      throw StateError(
        'Cannot write to a read-only buffer view (slave). '
        'Use cleanClone() to create a writable copy.',
      );
    }
    if (str.isEmpty) {
      return;
    }
    _data.chunks.add(str);
    _data.totalLength += str.length;
  }

  /// 从当前视图的头部“移除”并丢弃指定数量的字符直到index处。
  void popToIndex(int localIndex) {
    if (localIndex < 0 || localIndex >= length) {
      throw RangeError.range(localIndex, 0, length - 1, 'localIndex');
    }
    // 要弹出的字符数量是从 0 到 localIndex，总共 localIndex + 1 个
    pop(localIndex + 1);
  }

  /// 从当前视图的头部“移除”并丢弃指定数量的字符。
  ///
  /// 这个操作只推进当前实例的读取指针，不影响其他实例。
  /// 这是一个高效的操作，因为它不复制任何数据。
  void pop(int count) {
    if (count < 0) throw ArgumentError('Count cannot be negative.');
    if (count > length)
      throw ArgumentError('Count cannot be greater than the buffer length.');
    if (count == 0) return;
    _consumedLength += count;
    int remainingToPop = count;

    while (remainingToPop > 0 && _startChunkIndex < _data.chunks.length) {
      final currentChunk = _data.chunks[_startChunkIndex];
      final remainingInChunk = currentChunk.length - _startCharOffset;

      if (remainingToPop < remainingInChunk) {
        _startCharOffset += remainingToPop;
        break;
      } else {
        remainingToPop -= remainingInChunk;
        _startChunkIndex++;
        _startCharOffset = 0;
      }
    }
  }

  String substring(int start, [int? end]) {
    final int effectiveEnd = RangeError.checkValidRange(start, end, length);
    final int lengthToCopy = effectiveEnd - start;
    if (lengthToCopy == 0) return '';

    // (其余逻辑与 v2.3 相同，它已经足够健壮)
    int currentChunkIndex = _startChunkIndex;
    int currentCharOffset = _startCharOffset;
    int remainingToSkip = start;
    while (remainingToSkip > 0) {
      final availableInChunk =
          _data.chunks[currentChunkIndex].length - currentCharOffset;
      if (remainingToSkip < availableInChunk) {
        currentCharOffset += remainingToSkip;
        break;
      } else {
        remainingToSkip -= availableInChunk;
        currentChunkIndex++;
        currentCharOffset = 0;
      }
    }
    final resultParts = <String>[];
    int remainingToCopy = lengthToCopy;
    while (remainingToCopy > 0 && currentChunkIndex < _data.chunks.length) {
      final currentChunk = _data.chunks[currentChunkIndex];
      final availableInChunk = currentChunk.length - currentCharOffset;
      final toCopyFromThisChunk = min(remainingToCopy, availableInChunk);
      resultParts.add(
        currentChunk.substring(
          currentCharOffset,
          currentCharOffset + toCopyFromThisChunk,
        ),
      );
      remainingToCopy -= toCopyFromThisChunk;
      currentChunkIndex++;
      currentCharOffset = 0;
    }

    return resultParts.join('');
  }

  /// - 如果提供了 [end]，则返回一个固定长度的、不可变的“快照”。
  /// - 如果未提供 [end]，则返回一个共享数据的、动态长度的“视图”。
  ChunkedStringBuffer subBuffer(int start, [int? end]) {
    final int effectiveEnd = RangeError.checkValidRange(start, end, length);

    int newStartChunkIndex = _startChunkIndex;
    int newStartCharOffset = _startCharOffset;
    int remainingToSkip = start;
    while (remainingToSkip > 0) {
      final availableInChunk =
          _data.chunks[newStartChunkIndex].length - newStartCharOffset;
      if (remainingToSkip < availableInChunk) {
        newStartCharOffset += remainingToSkip;
        break;
      } else {
        remainingToSkip -= availableInChunk;
        newStartChunkIndex++;
        newStartCharOffset = 0;
      }
    }

    final newConsumedLength = _consumedLength + start;

    // 关键逻辑：如果 end 存在，则计算并设置固定的 _endMasterIndex
    final int? newEndMasterIndex = (end != null)
        ? _consumedLength + effectiveEnd
        : _endMasterIndex; // 否则继承父视图的边界
    return ChunkedStringBuffer._internal(
      _data,
      isReadOnly: true,
      startChunkIndex: newStartChunkIndex,
      startCharOffset: newStartCharOffset,
      consumedLength: newConsumedLength,
      endMasterIndex: newEndMasterIndex,
    );
  }

  /// 创建一个共享内部数据的只读视图 (Slave)。
  ///
  /// 返回一个新的 [ChunkedStringBuffer] 实例，它与原始实例共享
  /// 底层的字符串块列表，但拥有自己独立的读取指针。
  /// 这个新实例是只读的 (`isReadOnly = true`)。
  ChunkedStringBuffer clone() {
    return ChunkedStringBuffer._internal(
      _data,
      isReadOnly: true,
      startChunkIndex: _startChunkIndex,
      startCharOffset: _startCharOffset,
      consumedLength: _consumedLength,
      endMasterIndex: _endMasterIndex, // 克隆体继承边界
    );
  }

  /// 创建一个全新的、完全独立的、可写的缓冲区。
  ///
  /// 这个方法会复制当前实例视图内的所有数据到一个新的缓冲区中。
  /// 返回的实例是一个新的 Master，与原始实例不再有任何数据共享。
  ChunkedStringBuffer cleanClone() {
    final newBuffer = ChunkedStringBuffer();
    if (isEmpty) return newBuffer;
    newBuffer.write(this.toString()); // toString() 已经受 length 限制
    return newBuffer;
  }

  /// 将当前视图的所有内容合并并返回一个单独的 [String]。
  @override
  String toString() {
    // 这个方法不需要改变，因为它依赖于 `length`，而 `length` 已经正确处理了快照边界
    if (isEmpty) return '';
    final parts = <String>[];
    // 添加第一个可能不完整的块
    var currentLength = 0;
    if (_data.chunks[_startChunkIndex].length > (_startCharOffset + length)) {
      parts.add(
        _data.chunks[_startChunkIndex].substring(
          _startCharOffset,
          _startCharOffset + length,
        ),
      );
    } else {
      parts.add(_data.chunks[_startChunkIndex].substring(_startCharOffset));
    }
    currentLength = parts.first.length;
    // 添加所有后续的完整块
    for (int i = _startChunkIndex + 1; i < _data.chunks.length; i++) {
      if (length < _data.chunks[i].length + currentLength) {
        parts.add(_data.chunks[i].substring(0, length - currentLength));
        break;
      } else {
        parts.add(_data.chunks[i]);
        currentLength += _data.chunks[i].length;
      }
    }
    return parts.join('');
  }

  String toStringWithTrailing(String trailing) {
    // 这个方法不需要改变，因为它依赖于 `length`，而 `length` 已经正确处理了快照边界
    if (isEmpty) return '';
    final parts = <String>[];
    // 添加第一个可能不完整的块
    var currentLength = 0;
    if (_data.chunks[_startChunkIndex].length > (_startCharOffset + length)) {
      parts.add(
        _data.chunks[_startChunkIndex].substring(
          _startCharOffset,
          _startCharOffset + length,
        ),
      );
    } else {
      parts.add(_data.chunks[_startChunkIndex].substring(_startCharOffset));
    }
    currentLength = parts.first.length;
    // 添加所有后续的完整块
    for (int i = _startChunkIndex + 1; i < _data.chunks.length; i++) {
      if (length < _data.chunks[i].length + currentLength) {
        parts.add(_data.chunks[i].substring(0, length - currentLength));
        break;
      } else {
        parts.add(_data.chunks[i]);
        currentLength += _data.chunks[i].length;
      }
    }
    parts.add(trailing);
    return parts.join('');
  }

  /// 清空缓冲区。
  ///
  /// **注意:** 只有 Master (可写) 实例才能调用此方法。它会清空
  /// 共享数据，影响所有相关的视图。
  void clear() {
    if (isReadOnly) {
      throw StateError('Cannot clear a read-only buffer view (slave).');
    }
    _data.chunks.clear();
    _data.totalLength = 0;
    _startChunkIndex = 0;
    _startCharOffset = 0;
    _consumedLength = 0;
    // _endMasterIndex 是 final 的，Master 永远为 null，所以没问题
  }

  String operator [](int index) {
    if (index < 0 || index >= length) {
      throw RangeError.index(index, this, 'index');
    }
    int targetIndex = index;
    int currentChunkIndex = _startChunkIndex;
    int currentCharOffset = _startCharOffset;
    while (currentChunkIndex < _data.chunks.length) {
      final chunk = _data.chunks[currentChunkIndex];
      final availableInChunk = chunk.length - currentCharOffset;
      if (targetIndex < availableInChunk) {
        return chunk[currentCharOffset + targetIndex];
      } else {
        targetIndex -= availableInChunk;
        currentChunkIndex++;
        currentCharOffset = 0;
      }
    }
    throw StateError(
      'Internal error: Failed to find character at index $index',
    );
  }
}

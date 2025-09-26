#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

// 保持原有的常量定义
const float uGridSpacingX = 50.0;        // 网格X轴间距
const float uGridSpacingY = 50.0;        // 网格Y轴间距
const float uStartX = 0.0;               // 网格起始X坐标
const float uStartY = 0.0;               // 网格起始Y坐标
const float uIntersectionRadius = 2.0;   // 交点圆点半径
const vec4 uIntersectionColor = vec4(0.85, 0.85, 0.85, 1.0); // 淡灰色点
const vec4 uViewport = vec4(0.0, 0.0, 10000.0, 10000.0);       // 视口范围

out vec4 fragColor;

// 改进的平滑步进函数，提供更好的抗锯齿效果
float smoothStep(float edge0, float edge1, float x) {
    float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0); // 更高精度的平滑插值
}

// 改进的圆形抗锯齿函数
float getCircleAlpha(float dist, float radius) {
    float pixelRange = 0.5; // 减小像素范围以获得更锐利的边缘
    return 1.0 - smoothStep(radius - pixelRange, radius + pixelRange, dist);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    float x = fragCoord.x;
    float y = fragCoord.y;

    float viewportLeft = uViewport.x;
    float viewportTop = uViewport.y;
    float viewportRight = uViewport.z;
    float viewportBottom = uViewport.w;

    // Discard fragments outside the viewport
    if (x < viewportLeft || x > viewportRight || y < viewportTop || y > viewportBottom) {
        fragColor = vec4(0.0);
        return;
    }

    float intersectionAlpha = 0.0;

    // 计算最近的网格点
    if (uIntersectionRadius > 0.0 && uGridSpacingX > 0.0 && uGridSpacingY > 0.0) {
        // 使用floor函数更精确地定位网格点
        float xSteps = floor((x - uStartX) / uGridSpacingX + 0.5);
        float ySteps = floor((y - uStartY) / uGridSpacingY + 0.5);
        vec2 intersection = vec2(
            uStartX + xSteps * uGridSpacingX,
            uStartY + ySteps * uGridSpacingY
        );
        
        // 检查交点是否在视口内
        if (intersection.x >= viewportLeft && intersection.x <= viewportRight &&
            intersection.y >= viewportTop && intersection.y <= viewportBottom) {
            float dist = distance(fragCoord, intersection);
            intersectionAlpha = getCircleAlpha(dist, uIntersectionRadius);
        }
    }

    // 输出最终颜色
    fragColor = uIntersectionColor * intersectionAlpha;
}

---
trigger: always_on
---

当使用dart的时候，务必使用dart的 mcp server 暴露的命令，而不是直接运行cmd line版本的dart指令。否则的话，一定会导致权限不足引发问题的！
当flutter编码的时候，对于颜色透明度部分，不要使用withOpacy，使用新的withalpha方法
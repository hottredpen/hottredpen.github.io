---
title: Hexo中使用mermaid
date: 2020-11-12 10:49:15
tags:
    -hexo
    -mermaid
---


### 参考
https://blog.csdn.net/Olivia_Vang/article/details/92987859


### 安装插件
```
npm install hexo-filter-mermaid-diagrams
```
### 修改配置文件
在hexo的_config.yml文件（根目录的并非主题的）中，添加以下内容：
```js
# mermaid chart
mermaid: ## mermaid url https://github.com/knsv/mermaid
  enable: true  # default true
  version: "7.1.2" # default v7.1.2
  options:  # find more api options from https://github.com/knsv/mermaid/blob/master/src/mermaidAPI.js
    #startOnload: true  // default true

```

### js文件修改

`themes/next/layout/_partials/footer.swig`

以下是在next的footer.swig添加的内容。其他格式参考github: hexo-filter-mermaid-diagrams
```js
{% if theme.mermaid.enable %}
  <script src='https://unpkg.com/mermaid@{{ theme.mermaid.version }}/dist/mermaid.min.js'></script>
  <script>
    if (window.mermaid) {
      mermaid.initialize({{ JSON.stringify(theme.mermaid.options) }});
    }
  </script>
{% endif %}
```

效果
```
` ` `mermaid
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
` ` `
```

```mermaid
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
```

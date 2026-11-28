影视窗
<img width="1281" height="906" alt="image" src="https://github.com/user-attachments/assets/d41b6433-37db-4652-b894-1831f23dcad4" />


极简的 Windows 影视聚合播放器（基于TVBOX Desktop修改）,适配安卓 TVBox 的配置订阅格式，用桌面端更好用的交互方式呈现。

版本
0.1.30（package.json / package-lock.json 三处版本号同源）
技术栈
Electron 44 + React 19 + TypeScript + Vite + zustand，ArtPlayer + hls.js
形态
便携 —— 配置、缓存与下载记录都在程序同级的 data\，不写 C 盘用户目录
验证
npm run typecheck / npm run build 干净；npm run selftest 端到端自检覆盖十三块
内容
不内置任何影视源：没有采集接口、没有直播源、没有推荐订阅

设计文档（功能范围 / JSON 格式规范 / 里程碑）：见 功能框架.txt
逐版本变更与每一轮修补记录：见 CHANGELOG.md

下载安装
去 Releases 下载 Assets 里的 影视窗-<版本>-编译版.zip（约 168 MB）：
解压到任意目录（别放进 C:\Program Files 这类要管理员权限的位置，否则 data\ 写不进去）。
双击 影视窗.exe，免安装，配置与缓存就落在同级的 data\。
程序没有代码签名证书，首次运行 Windows SmartScreen 会拦一下：点「更多信息」→「仍要运行」。这不是病毒提示，只是没买证书。
装完先看声明，源由你自己加
这个版本不内置任何影视源。 程序里没有片源、没有采集接口、也没有播放地址 —— 它就是一只空壳客户端，内容全部来自你自己添加的第三方配置源。
第一次打开会先弹一份使用声明（软件不含任何影视资源、对外不提供接口、不含破解功能、打赏自愿），点「我已阅读并同意」才进主界面，不同意直接退出；同意一次就不再提示（记在 data\disclaimer.json，改声明文案会把版本号 +1 重新弹）。
同意之后是首启引导页：到「影视源」页填入你自己的订阅地址，或选择一个本地 .json 配置文件，同步一次就能用。
配置源、API Key、外部播放器路径、收藏与观看历史都只留在本机 data\，不会跟着压缩包发出去。

快速开始
npm install          # 首次安装会自动补下载 Electron 二进制（走 npmmirror）
npm run dev          # 启动开发窗口

如果 Electron 二进制没下下来（国内直连 GitHub Releases 会失败），手动执行：
$env:ELECTRON_MIRROR="https://npmmirror.com/mirrors/electron/"
node node_modules/electron/install.js

npm 脚本
命令
作用
npm run dev
启动开发窗口（渲染进程热更新）
npm run dev:debug
同上，另外打开 CDP 调试端口 9222
npm run selftest
端到端自检：起本地桩服务器 + 驱动窗口，十三块断言
npm run typecheck
主进程与渲染进程双工程类型检查
npm run build
产出 out/（主进程 /preload/ 渲染进程）
npm run build:win
electron-builder 打包出 NSIS 安装包与免安装 zip

国内网络下要给 builder 自己的二进制也指个镜像，否则下载 nsis / 7zip 会卡住：
$env:ELECTRON_BUILDER_BINARIES_MIRROR="https://npmmirror.com/mirrors/electron-builder-binaries/"
npm run build:win

应用图标是代码生成的，不依赖任何设计工具：改完配色或造型跑一次就会重新写出 build/icon.png（512×512）与多尺寸 build/icon.ico。
node scripts/make-icon.mjs


目录结构
src/
  shared/             主进程与渲染进程共用
    types.ts            Site / Vod / VodDetail / AppSettings / UpdateCheckResult ...
    ipc.ts              IPC 通道常量
    skins.ts            11 套皮肤定义（light / mist / forest / rose / sepia / dark /
                        graphite / teal / violet / coffee / ink）
    siteLabels.ts       站点类型的中文名与色签
  main/               主进程
    index.ts            窗口创建、生命周期、IPC 处理器注册、启动预热与静默版本自检
    services/
      store.ts          JSON 落盘（内存缓存 + 防抖 + 临时文件改名）
      http.ts           统一网络层（UA / 超时 / GBK 解码 / header 通配规则 / 连接重试）
      cms.ts            苹果CMS 地址构造与返回判定
      config.ts         配置 JSON 归一化（A 方言与 B 方言都能吃）
      sources.ts        配置源增删改查、同步、启动回填
      sites.ts          影视源汇总去重、本地覆盖、连通性测试
      customSites.ts    用户手动加的站点
      customLives.ts    用户手动加的直播频道
      settings.ts       应用设置（含语言、海报缓存上限）
      presets.ts        内置推荐订阅（本版本故意为空数组）
      search.ts         聚合搜索（并发池 + 流式进度 + 可取消）
      category.ts       分类浏览（分类树归并大类 / 子分类、逐叶子拉页、预取下一页）
      detail.ts         详情与选集解析（CMS / 网页规则两条路）
      htmlRules.ts      网页规则取值语法（选择器 || 属性 && 提取）
      home.ts           首页内容位（读配置里的 home.sections，没配就每源一条「最近更新」）
      player.ts         外部播放器探测与唤起（扫常见路径 + 问注册表默认打开方式）
      live.ts           直播源解析（m3u / txt 两套语法 → 按频道名合并成一卡多线路）
      liveHealth.ts     直播线路体检（只读 4KB 判活 + 抓最高档画质；成功 30 分钟 / 失败 5 分钟）
      streamResolve.ts  房间号频道换真地址（huya:// / douyin:// → 带防盗链的 m3u8）
      proxy.ts          启动时探一次系统代理，端口连不上就改为直连
      library.ts        收藏与观看历史（json 落盘，历史留 200 条；按归一化片名跨源合并）
      ai.ts             AI 剧情总结（文字 / 看片两条路，Key 不出主进程）
      synopsis.ts       剧情简介抓取（网络 / 百度百科）
      poster.ts         海报图缓存与自动清理（上限由设置页决定，默认 200 MB）
      parse.ts          解析接口（直链放行 → 自己读播放页 → 按排行问接口）
      download.ts       下载（HLS 分片 / 直链 Range 续传 / .part 半成品）
      downloads.ts      下载任务队列与落盘（最多同时 2 条）
      disclaimer.ts     首启使用声明（版本号 + 同意状态）
      update.ts         版本检测（查 GitHub 最新 Release）
  preload/            contextBridge 暴露 window.api
  renderer/           React 界面
    src/i18n.ts       中英文字典与 useT()（只翻「外壳」）
    src/pages/         Home / Search / Detail / Player / Live / LocalPlay / Library /
                       Downloads / Sites / Settings
    src/components/    HeroCarousel / HomeRail / VodCard / Poster / MiniDock / TopBar /
                       TopMenu / Sidebar / SkinSwitcher / LanguageSwitch / Disclaimer /
                       AiSummary / Synopsis / Toasts / Switch / EmptyState / Roadmap / icons
    src/styles/        tokens.css（皮肤变量）+ global.css + pages.css + skin.css
    src/utils/         media.ts（直链判定与默认线路）/ frames.ts（抽帧）/
                       normalize.ts（片名归一化）/ remarks.ts（下线标签兜底）/
                       format.ts / vodLink.ts / artplayer.ts / pipDock.ts
    src/store/useApp.ts 全局状态；mergeResults() 同名合并、findSourceGroup() 换源分组
samples/
  demo-config.json     示例订阅（B 方言，含各种站点类型，域名全是占位）
  selftest-config.json 自检用配置（全部指向本地桩服务器）
scripts/
  ensure-electron.cjs  postinstall 时补下载 Electron
  make-icon.mjs        生成 build/icon.png 与多尺寸 icon.ico（零依赖）
  selftest.mjs         端到端自检
  stub-server.mjs      本地桩服务器（苹果CMS + 网页规则站 + 假 m3u8 + 占位海报）
  eval.mjs             往运行中的窗口丢一段 JS 执行
  shot.mjs             按 CDP 截图
build/
  icon.png / icon.ico  应用图标
electron-builder.yml   打包配置（NSIS + zip，产物落 release/）


配置 JSON 怎么写
两种方言都能吃，扩展字段统一放在 tvboxDesktop 键下，对安卓 TVBox 无副作用。
A 方言：直接填现成的 TVBox 订阅地址，原样解析。
B 方言（手写推荐）：
{
  "format": "tvbox-desktop/1",
  "name": "我的订阅",
  "sites": [
    {
      "key": "example_cms",
      "name": "示例站",
      "type": "cms",
      "api": "https://example.com/api.php/provide/vod",
      "searchable": 1
    }
  ],
  "lives": [{ "name": "直播源", "url": "https://example.com/live.txt" }],
  "parses": [{ "name": "解析", "type": 1, "url": "https://example.com/jx?url=" }],
  "headers": [{ "host": "*.example.com", "header": { "User-Agent": "okhttp/3.12.0" } }],
  "tvboxDesktop": {
    "home": {
      "sections": [
        { "title": "电影 · 最近更新", "site": "example_cms" },
        { "title": "电影 · 动作片", "site": "示例站", "typeId": 6 }
      ]
    }
  }
}

站点 type 可以是数字或字符串：
值
含义
桌面端
3 / "cms"
苹果 CMS（主力）；api 可写基地址，也可写带 {ac}{wd}{pg}{t}{ids} 占位符的模板
✅ 搜索 + 分类浏览
1 / "html"
网页规则站，靠 rules 里的 CSS 选择器抓取
✅ 仅搜索
4 / "api"
CMS 变体
✅ 搜索 + 分类浏览
0 / "spider"
需要配套 jar/dex，桌面端跑不了
❌ 灰显并说明原因
2 / 其它
未知类型
❌ 灰显并说明原因

站点级可选字段：searchable、quickSearch、filterable、categories、header、timeout、enabled。
拿 samples/demo-config.json 练手最快：里面的站点全是 demo-*.example.com 占位域名，只用来验证「配置能读进来、界面能渲染」，播不出画面。
内置推荐订阅（本版本故意为空）
公开版本不带任何内置订阅：src/main/services/presets.ts 里的 SOURCE_PRESETS 是空数组，addPreset() 直接抛「这个版本不带内置订阅」，ensureBundledSources() 恒返回 false。装完打开是首启引导页，源全部由用户自己添加 —— 这样发到 GitHub 的压缩包和源码里都不含任何影视接口。
首启页 / 设置页的「一键添加内置订阅」区块按数据渲染，数组为空就整块不显示，界面不用改。
以后真要再带一份内置订阅：往 SOURCE_PRESETS 里塞一个 SourcePreset 即可。

首页
首页上下两段：
轮播：网络里挑 7 部（电影 / 剧集混排），左边简介右边竖版海报，底部圆点可切，5 秒自动翻页；片名、年份、地区、类型来自网络，简介会截断到三行。
精选四行：电影 · 精选、剧集 · 精选、综艺 · 精选、动漫 · 精选，数据来自网络榜单，卡片角上是评分，横向滚轮或左右箭头翻，右上角「更多」跳分类页。
想看自己订阅源的排行，可以在配置里写 tvboxDesktop.home.sections（见上一节）：
site 既可以是站点 key，也可以写站点中文名（key 精确 → 中文名精确 → 忽略大小写 → 互相包含）。
写了 typeId 就是「分类推荐」，不写就是该源的「最近更新」。
没配就每个可用源给一条，行尾打一个「自动」标签。
一行拉不到不影响别人：写错的源只会让那一行显示一行错误文字，其余照常画。
结果在主进程里缓存 10 分钟，失败的只缓存 1 分钟；hero 上的「刷新内容位」是强制重拉。
搜索
顶部搜索框回车即聚合搜索：并发池按站点并发（并发数可在设置里 1–32），结果一条条流式推过来，中途可以取消。同名影片跨站合并成一张卡并标「N 个源」，鼠标悬停能看到具体站点。
解说过滤：默认挡掉 [电影解说] / 「一口气看完」这类二创内容，搜索页副标题会写明挡掉了多少条。判定看两条线索：片名关键词，或者分类字段（vod_class / type_name）是「影视解说」。
一个站点只留一条：同一站对同一部剧返回多条时，按「有海报 > 有备注 > 有评分，同分取名字短的」只保留信息量最大的一条。
别名括号会去掉：庆余年，全世界都以为我是废物太子（庆余年之大凉太子爷） 与不带括号的合成一条；但括号里是分季分集信息时（第61-81集、特别篇）会保留。
分类浏览
侧栏第三项。没有搜索框—— 找片名用顶部全局搜索，这一页是「不知道看什么」时用的目录。
打开时向每个可搜索的 CMS 站点拉一次 ac=list，拿到各自的分类树后归并成统一大类（电影 / 电视剧 / 动漫 / 综艺 / 纪录片 / 短剧 / 体育 / 少儿），点进大类后上方出现一行子分类标签，标签上的数字是覆盖到几个站点。分类结果缓存 10 分钟。
归并是对着整条祖先链做的，不是只看顶层：
记录片 挂在「电影片」下面，且写的是「记录」不是「纪录」—— 漏了这个字就会留在电影里；
短剧 挂在「连续剧」下面，要拆出来；
动画片 归哪儿看父分类：挂「动漫片」下归动漫，挂「电影片」下归 电影 → 动画；
伦理片 在部分站是子分类，SKIP 规则沿祖先链生效，命中就整棵子树丢掉。
尺度过滤只按分类名挡，且只在分类浏览里生效，聚合搜索不受影响。
滚到底会自动加载下一页（IntersectionObserver 提前 500px），首屏一画完就在后台预取下一页，滚到底时直接换上。翻页时已上屏的卡片不会被重排：mergeResults() 收一个 previousOrder，排完序把出现过的按原名次放回，新出现的接在后面。
详情与选集
从列表点进详情，先把已经拿得到的显示出来—— 片名、海报、评分、备注都来自结果列表那份数据，线路和剧集在后面加载，期间骨架占位。
详情页有独立的「选择片源」区块，列出这部片子在每个站点的条目（当前这条标「正在看」），点一下换过去；片名与当前不同的会显示「该源片名：…」。
pickPlayableLine() 默认选中第一条看起来是直链的线路（采集站经常把分享页放第 1 条、真 m3u8 放第 2 条），已经在放但线路不对时播放页会给「换到某线路试试」的入口。
播放
内嵌播放器是 ArtPlayer + hls.js：倍速、进度条、全屏、画中画都在。浏览器放不了的格式，点「外部播放器」唤起本机 PotPlayer /mpv/ VLC。
播放地址是个可点的小方框：点了用系统默认浏览器打开，右边「复制地址」可拷走。
切页不断播：切到别的页面时，正在播的视频缩进右下角小窗继续放（MiniDock），点「回到播放页」按上次进度接着看。
画中画不暂停：开着系统画中画时关窗，视频继续播放，画面留在桌面上；没开画中画时关窗先暂停。
播放页直接换片源：侧栏顶部「片源」区块列出各站点的条目，点一下就换过去继续看；没走过搜索时点「找其它片源」会按片名现搜一次。
设置页能一键检测本机播放器：扫 PotPlayer /mpv/ VLC / MPC-HC / MPC-BE / KMPlayer / SMPlayer 的常见安装路径（含 PATH），还会问注册表里 .mkv / .mp4 / .ts / .flv 的默认打开方式。结果每条带「用这个」，点一下填进上面的输入框；已生效的标「已选」。
参数模板里 {url} 是播放地址、{title} 是片名，多个参数用空格分隔，例如 --fullscreen {url}。
解析接口
采集站的线路经常给的不是直链，而是一个分享页地址。这种地址丢给播放器只会黑屏，所以播放时走三步：
本来就是直链就直接放。只看协议和扩展名（m3u8 / mp4 / flv / mkv / ts / mpd…），不做域名白名单 ——CDN 域名天天换，白名单只会误伤。
先自己读一遍那个页面。十有八九是个 DPlayer 壳，地址明文写在 const vid = '…/index.m3u8' 里，抓出来就完事。
读不出来才按排行问解析接口。排行按「分档 → 战绩」：声明了匹配线路的优先，其次通配，最后声明了别的线路的；同档里按成功率（拉普拉斯平滑）和速度排。失败的会沉下去，越用越准。
没有内置任何第三方公开解析接口。 要不要加、加哪条，由你自己在设置页决定。来源只有两种：
来源
说明
配置里带的
订阅 JSON 里的 parses 数组，同步配置源后自动出现，不可单独删除
手动添加
设置页「解析接口」区块里加的，落盘在 data\parses.json，可删

type=0（需要浏览器嗅探的那种）会打警示标签：它靠前端 JS 算地址，HTTP 解析拿不到，目前只支持 type=1/2。换地址失败时播放器会写出每一条路子分别为什么失败，不假装成功。
电视直播
直播源支持 m3u 与 txt 两套语法，同一频道的多个来源合并成一张卡、一张卡上多条线路。
真正的问题不是源少，而是死链多，所以做法是「把已有的线路用起来」：
进分组后后台预热：当前分组前 60 条可探地址交给主进程，每次最多 8 条并发、只读到 4 KB 就断开（直播流不会结束，绝不能整条拉完），顺带从 m3u8 头里记下最高一档画质。成功缓存 30 分钟、失败只缓存 5 分钟。
点开频道优先用探到的线路；播放中途拉流失败自动换下一条，并提示「这条线路拉不起来，已自动换到第 N / M 条」。
整组都探不到的频道默认藏起来，顶部给「显示 N 个不可用」开关；频道卡标 2/2 线，不可用的打虚线写「不可用」。
右上角「体检线路」= 清空体检表重测一遍。体检请求会带上配置里的请求头（不少直播网关校验 Referer/UA）。
画质上起播直接选最高档（hls.nextLevel，不是会把 ABR 钉死的 currentLevel），之后仍允许 ABR 降档。
房间号频道（huya:// / douyin://）
虎牙、抖音这类平台的直播地址带防盗链签名、几小时就失效，所以直播源里只写房间号：
游戏赛事,#genre#
danking直播,huya://10188

只有点开这个频道时才去平台换真地址（走一次 IPC，不是页面里直接请求），换好了才构造播放器。主播没开播时播放区显示「换不到播放地址」+ 原因 + 重试，而不是黑屏。
收藏与观看历史
历史每条记下看到第几集、看到哪个时间点、以及是哪个源。
同一部剧在多个源上看过只算一条：分组发生在读取时，按归一化片名归并（全角转半角、统一小写、去空格与标点）。
归一化刻意保守：不剥「第二季」「(国语)」这类后缀。宁可漏合，也不要把不同季的进度串到一起。
一条里收着多个源时，行上出现「N 个源」与可点的源标签，主记录是最近看过的那条。
进度条只在知道时长时才画，右侧给出 看到 9:23 / 23:07；时长未知时留白，不画 0% 灰线。
删除删的是这部片在所有源上的记录，多源时先确认一次。
续播：从历史点进播放页会 seek 回上次位置。recordHistory() 同一集时只有拿到真实时长（duration > 0）才允许改写进度，避免一进页面就把上次进度抹成 0/0。
点历史时原源连不上会自动换源：按片名到其它已启用源找同一部，带上集数与进度切过去；「谁先返回同名结果就用谁」，不用等慢源超时。
下载
播放页「下载影视」把这一集丢进队列。
下载记录页分「正在下载 / 下载完成」：分段进度、百分比、速度、取消；完成后可打开所在文件夹、删除单条或清空。
断点续传：先写 <文件名>.part，每完成一段 / 每 1 MB 刷新任务档案。退出或崩溃后重启，中断的任务自动重新排队，从上次位置接着下。
HLS 记已完成分片数与清单指纹，重启后跳过已下分片、在 .part 末尾追加；清单变了（换码流 / 直播滚屏）指纹对不上就自动从头下。
直链用 HTTP Range 从 .part 的字节位置继续；服务器不认 Range（回 200）就退回从头下。
最多同时下 2 条，其余排队；失败 / 取消的任务可「重试」，接着 .part 续。主动取消会清掉半截文件。
关窗驻留托盘：有下载任务时点关闭只隐藏窗口，下载在主进程继续跑；托盘菜单显示任务数并可跳到「下载记录」。
完成提醒：响一声 + 系统通知，点通知回主界面；窗口在前台时另外弹一条 toast。
本地播放
侧栏「本地播放」。用系统对话框选一个磁盘上的视频，或直接把文件拖进窗口，就能在软件里播 ——不联网、不上传、不经过影视源。
最近放过的 12 个文件记在浏览器 localStorage（tvbox.local.recent），点一下接着看；文件被移走会提示并从列表里摘掉。
和在线播放共用一套播放器与 MiniDock：切页照样缩进右下角小窗继续放。
编码提示：mp4（H.264 / AAC）兼容最好；HEVC、DTS 这类要看系统解码器，播不了会在播放器里给出提示而不是白屏。
界面与外观
11 套皮肤：light /mist/forest /rose/sepia /dark/graphite /teal/violet /coffee/ink。顶栏「皮肤」里点选即时生效，落盘到 data\settings.json；标题栏明暗跟皮肤走。
强调色：设置里可选 accent，换色后顶栏、按钮、开关、进度条统一跟着变。
EN / CN 语言开关：顶栏搜索框右边。等宽两段 + 一块会滑的强调色滑块（220ms 缓动），切换时只有滑块平移，EN、CN 两个字固定原位不跳。选择落盘，下次启动还记着。
目前只翻「外壳」：侧栏导航、搜索占位、顶栏按钮（皮肤 / 同步配置）、赞助卡片标题、窗口三键提示、首启页、设置页四个分区标题与「版本检测」。页面正文与使用声明仍是中文。
海报图缓存大小：设置 → 通用 → 右列下拉框，200 / 300 / 400 / 500 MB，默认 200 MB。超过上限就按「最久没访问」从旧到新删 data\poster-cache 里的图片，不碰收藏、历史、配置源与下载；改完保存立即按新上限清一遍。
侧栏可收起：左下角「收起侧栏」，收起后只留图标位。
版本检测
设置页底部「版本」一栏显示当前版本号，右边「版本检测」按钮会去 GitHub 查最新 Release 比一比：
结果
显示
已是最新
已是最新版本（GitHub 上发布的是 x.y.z）
发现新版本
发现新版本 x.y.z + 「前往下载」（跳 Release 页）
本机更新
当前 x 比 GitHub 上的 y 新，无需更新
失败
检测失败 + 原因（连不上 GitHub 或还没发过 Release）

仓库写在 src/main/services/update.ts 的 UPDATE_REPO（byte-hop/Film-Window），公开仓库不需要 token，查不到也不影响正常使用。
启动后静默自检：进主界面 6 秒后自动查一次，只有确实比本机新才在右下角弹一条 toast 指路到「设置・版本」；离线、限流、还没发 Release 一律不打扰。
版本号解析两处都认：tag_name 或 Release 标题里第一个形如 x.y.z 的片段。发版时 tag 直接写 v0.1.30 这种最省事；写成别的（比如 Film-Window）只要标题里带版本号也能被认出来。
自检
# 终端 A
npm run dev:debug
# 终端 B
npm run selftest

自检起一个本地桩服务器（苹果 CMS + 网页规则站 + 假 m3u8 + 占位海报），再用 CDP 驱动真实窗口，覆盖十三块：六个路由渲染、配置解析、站点类型归一化、CMS 与网页规则站的连通性（含失败路径）、自定义请求头透传、搜索 → 详情 → 选集 → 播放器全链路（含同名合并、解说过滤、换片源）、分类浏览（大类归并、记录片 / 短剧 / 动画片归位、伦理片整棵子树丢掉、滚到底接下一页、翻页后位置稳定）、电视直播（两种格式、跨源同名合并、分组名去装饰、线路体检、死链隐藏开关、清空体检表）、收藏与观看历史（跨源合并、行上换源）、AI 剧情总结（区块位置、「点了才请求」、有无 Key 的分支）、解析接口（直链放行、读播放页、兜底轮询、战绩分档）、首页内容位（命名空间、按 key 与中文名找源、写错的源只报一行），以及页面无 JS 异常。
[9/13] 段要把收藏与历史清干净才对得上数目，所以脚本开头先备份、末尾再还原你真实的记录；updatedAt 会被刷新，还原后这些记录都显示「刚刚」。
自检刻意不真调 DeepSeek，只按设置里有没有 Key 分开断言界面该有的样子。
滚动加载这类依赖渲染帧的断言要求页面可见且聚焦（Page.bringToFront + Emulation.setFocusEmulationEnabled），否则 Chromium 会把 rAF 与 IntersectionObserver 完全节流。
系统代理
界面里的海报和视频走 Chromium，主进程的请求走 Node——两者对系统代理的处理不一样：Chromium 听 Windows 的代理设置，Node 的 fetch 根本不读它。
所以当 Windows 系统代理开着、代理软件却没在跑时（Clash 内核退了但 ProxyEnable 还留着），会出现「搜索、详情、分类、直播分组全正常，但界面里所有图片和视频都黑，控制台一片 ERR_PROXY_CONNECTION_FAILED」。
src/main/services/proxy.ts 在建窗口之前处理：用 resolveProxy 问出系统代理链，对每个 host:port 做一次 800ms TCP 探测，只要有一个在监听就照旧走系统代理，一个都连不上才把这次会话切成 direct:// 并打一条 [proxy] 警告。这个判断每次启动只做一次。
数据目录
配置、缓存、下载记录都在程序同级的 data\，不写 C 盘用户目录：
场景
位置
开发
<源码目录>\data\
打包后
<exe 所在目录>\data\

data/
  settings.json      应用设置（含语言、皮肤、海报缓存上限）   ← 别外传，里面有 API Key
  sources.json       配置源
  sites.json         站点本地覆盖
  custom-sites.json  手动添加的站点
  custom-lives.json  手动添加的直播频道
  parses.json        手动添加的解析接口
  history / favorites  观看历史与收藏（最多 200 条历史）
  downloads.json     下载任务
  disclaimer.json    首启声明同意状态
  poster-cache/      海报图缓存（按上限自动清理）
  home-cache.json / browse-cache.json / class-cache.json / category-index.json  各页快照
  live-health.json   直播线路体检结果
  session/           Chromium 缓存（会很大，删掉只影响下次启动稍慢）

如果这个位置建不出来（比如装到了只读目录），会自动退回系统默认的用户目录并在控制台提示。
已知限制
只支持桌面端能跑的站点类型：苹果 CMS（type 3/4）与网页规则站（type 1）。需要 jar/dex 的 spider（type 0）跑不了，会灰显并写明原因。
解析接口只做 HTTP 解析（type=1/2），type=0 的浏览器嗅探还没做。
首页内容位只按「最近更新」或指定分类拉一页（每行最多 24 条），没有「换一批」；配置里只能写 site / typeId。
外部播放器检测是扫路径 + 问注册表，不是遍历全盘；装在奇怪目录的播放器得手填一次。
播放进度取决于源：能直接给 m3u8 的源进度是真的，只给分享页地址的源拿不到进度；拿不到时长就不画进度条。
语言开关只翻「外壳」，页面正文与使用声明仍是中文。
没有代码签名证书，首次运行会触发 SmartScreen。
Windows 上点关闭只会收进托盘，要真退出走托盘菜单「退出影视窗」。
自己添加的采集站随时可能失效，在「影视源」页点「测试」就能看出来。

免责声明
本项目只是一个播放器壳，不含任何影视内容，也不提供、不托管、不存储任何视频资源。
不内置任何影视源：没有采集接口、没有直播源、没有推荐订阅。所有内容都来自使用者自己添加的第三方配置，软件按配置里写的地址去请求，就像浏览器按你输入的网址去访问一样。
配置里那些站点随时可能失效或变更，本项目的维护者不对其可用性、合法性、内容负责。
请仅将本项目用于学习 Electron / React / TypeScript 的桌面开发，并遵守你所在地区的法律法规。请通过官方渠道观看正版内容。
因使用本项目产生的任何后果，由使用者自行承担。
许可
MIT

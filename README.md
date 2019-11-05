### XTerminal是什么？
> 它就是终端Terminal，只不过它是简单阉割版，部分命令暂时不能支持。
> 
> 它虽是终端，但不止于终端，会集成各种快捷命令
> 
> *插件下载地址在本文最后*

### 为什么要造一个XTerminal？
> Apple很吝啬，始终不肯将terminal嵌入XCode中，像Android Studio，IDEA等都支持了。
>
> ##### 我们是否需要它？
> - 假如git操作常用SourceTree等客户端，可能对此插件需求不高。
> - 当然我们也可以使用XCode的Behaviors功能来打开一个iTerm2或者Terminal，假如对切屏无所谓，不在意的话（XCode开发中大部分都是全屏的，通过Behaviors打开一个终端肯定是切换屏幕的），那么也对此插价需求不高。
> - 假如你git操作常用命令，而且需要就在本屏幕内实现，那么你对此插件**需求很高**

### XTermimal支持命令
> [✔] all bash
>
> [✔] Cocoapods
> 
> [✔] 快速查看当前分支：shift+B
> 
> [✔] 快速打开Podfile：shift+P
> 
> [✔] 快速打开Podfile.lock：shift+L
>

### XTermimal不支持命令
> [❌] vim
> 
> [❌] cd
> 

### 安装插件
> XCode9以及以上请对XCode进行重签名（重签后无法上传ipa，一般公司都有专门的打包机，所以问题不大；否则自己备份下XCode）
> 
> 1.在钥匙串中创建代码签名：XcodeSigner
> 
> ![](http://xbqn.nbshk.cn/20191105144959_pOfzPS_Screenshot.jpeg)
> 
> ![](http://xbqn.nbshk.cn/20191105145131_lOCLuq_Screenshot.jpeg)
> 
> 2.重签XCode
> 
```
sudo codesign -f -s XcodeSigner /Applications/Xcode.app 
```
> 
> 3.首先查看你安装的XCode的PluginUUID是否存在info.list
> 
> 若不存在，可以自行增加到info.list再运行
> 
```
find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add DF11C142-1584-4A99-87AC-1925D5F5652A
```
> 
> 
> 4.启动后，点击**Load bundle**即可安装成功
> 
> ![](http://xbqn.nbshk.cn/20191105145203_6Lwy9f_Screenshot.jpeg)
> 
> 5.XTernimal是在Window菜单下面
> 
> ![](http://xbqn.nbshk.cn/20191105145535_kqqHtr_%E6%88%AA%E5%B1%8F2019-11-05%E4%B8%8B%E5%8D%882.55.13.jpeg)
>
> 6.插件的安装目录
> 
```
~/Library/Application Support/Developer/Shared/Xcode/Plug-ins
```


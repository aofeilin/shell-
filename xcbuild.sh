#!/bin/sh
#第一行必须写 告诉终端下面是执行的命令
#Author: Bevis
#颜色
yellowColor='\033[1;33m'
clearColor='\033[0m' # No Color
#alert
notifyBuildProcessWithText(){
text="$1"
echo "${yellowColor} $text ${clearColor}"
osascript -e "display notification \"$text\" with title \"xcbuild\" "
}


# 4. clean, build, archive and package
buildDir=firBuild
TARGET_NAME=promotion_sales
ARCHIVE_PATH=$buildDir/${TARGET_NAME}.xcarchive
#这个是中间文件目录。需要export出ipa文件
logPath=$buildDir/buildLog

notifyBuildProcessWithText "Cleaning"
time xcodebuild -workspace promotion_sales.xcworkspace -scheme promotion_sales clean | xcpretty --color >> $logPath
notifyBuildProcessWithText "Building"
time xcodebuild -workspace promotion_sales.xcworkspace -scheme promotion_sales | xcpretty --color >> $logPath
notifyBuildProcessWithText "Archiving"
time xcodebuild archive -workspace promotion_sales.xcworkspace -scheme promotion_sales -configuration Debug -archivePath $ARCHIVE_PATH DEPLOYMENT_POSTPROCESSING=YES | xcpretty --color >> $logPath
notifyBuildProcessWithText "Exporting"
#导出  sign project
time xcodebuild -exportArchive -archivePath $ARCHIVE_PATH -exportPath $buildDir -exportOptionsPlist exportOptions.plist >> $logPath

#上传到fir
notifyBuildProcessWithText "上传fir"
#这里写fir token
firApiToken="******需要填写fir token*******"
ipaPath=${buildDir}/${TARGET_NAME}.ipa
time fir publish  -T $firApiToken  $ipaPath
#终端运行

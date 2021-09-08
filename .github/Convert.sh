
home="."
#home="${0%/*}"

sed -i "/^若使用有问题/c 若使用有问题，请建立issues。\`$(date "+%Y-%m-%d %H:%M:%S")\`" "${home}/README.md"

Latest_version="$(curl "https://github.com/YAWAsau/backup_script/releases" -sL | awk -F "/YAWAsau/backup_script/releases/download" '{print $2}' | awk -F ".zip" '{print $1}')"
Latest_version="$(echo ${Latest_version} | awk -F "/" '{print $2}')"
echo "ReleaseVersion=${Latest_version}" >> ${GITHUB_ENV}

[ ! -d "${home}/zip" ] && echo "- 创建zip目录" && mkdir -p ${home}/zip
[ -f "${home}/zip/version" ] && Previous_version="$(cat ${home}/zip/version)" || Previous_version=""

if [ "${Previous_version}" != "${Latest_version}" ]; then

  echo "Judgement_Push=true" >> ${GITHUB_ENV}

  rm -rf ${home}/zip/v${Previous_version}.zip 1>/dev/null 2>&1
  echo "${Latest_version}" > "${home}/zip/version"

  echo "- 创建${home}/Download目录"
  mkdir -p ${home}/Download

  echo "- v${Latest_version}.zip文件下载至${home}/Download目录"
  curl -o "${home}/Download/v${Latest_version}.zip" "https://github.com/YAWAsau/backup_script/releases/download/${Latest_version}/v${Latest_version}.zip" -sL

  echo "- 查看${home}/Download/v${Latest_version}.zip文件大小"
  ls -lh ${home}/Download/v${Latest_version}.zip

  echo "- 创建${home}/v${Latest_version}目录"
  mkdir -p ${home}/v${Latest_version}

  echo "- 解压v${Latest_version}.zip到${home}/v${Latest_version}目录"
  7za x ${home}/Download/v${Latest_version}.zip -o${home}/v${Latest_version} -aoa

  echo "- 列出${home}/v${Latest_version}目录文件/文件夹"
  ls ${home}/v${Latest_version}

  echo "- 开始转换"
  # 转文件名为简体
  for file in `find ${home} -type f -name "*.sh" -or -name "*.zip"`
  do
    echo "${file}"
    mv "${file}" "$(echo "${file}" | opencc -c t2s)" 1>/dev/null 2>&1
  done

  # 转文件内容为简体
  for file_Content in `find ${home} -type f -name "*.md" -or -name "*.conf" -or -name "*.sh" -or -name "restore*" -or -name "update-binary" -or -name "toast"`
  do
    echo "${file_Content}"
    opencc -i ${file_Content} -c t2s -o ${file_Content} 1>/dev/null 2>&1
  done
  echo "- 转换完成!"

  echo "- 压缩${home}/v${Latest_version}目录下所有文件到${home}/zip/v${Latest_version}.zip"
  zip -r ${home}/zip/v${Latest_version}.zip ${home}/v${Latest_version}/*

  echo "- 查看${home}/zip/v${Latest_version}.zip文件大小"
  ls -lh ${home}/zip/v${Latest_version}.zip

  sed -i "/| :----: | :----: | :----: |/a\\| $(date "+%Y-%m-%d %H:%M:%S") | v${Latest_version} | [Download](https://github.com/Petit-Abba/backup_script_zh-CN/releases/download/${Latest_version}/v${Latest_version}.zip) |" "${home}/README.md"
  [ "$?" == "0" ] && echo "(&) 输出完成！"

  rm -rf ${home}/Download/
  rm -rf ${home}/v${Latest_version}/
fi

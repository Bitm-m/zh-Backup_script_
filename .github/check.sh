
home="."
sed -i "/^若使用有问题/c 若使用有问题，请建立[issues](https://github.com/Petit-Abba/backup_script_zh-CN/issues)。\`$(date "+%Y-%m-%d %H:%M:%S")\`" "${home}/README.md"

Latest_version="$(curl "https://github.com/YAWAsau/backup_script/releases" -sL | awk -F "/YAWAsau/backup_script/releases/download" '{print $2}' | awk -F ".zip" '{print $1}')"
Latest_version="$(echo ${Latest_version} | awk -F "/" '{print $2}')"
[ -f "${home}/zip/version" ] && Previous_version="$(cat ${home}/zip/version)" || Previous_version=""

echo "- 当前时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "- 原仓库最新版本: v${Latest_version}"
echo "- 本仓库最新版本: v${Previous_version}"
if [ "${Previous_version}" != "${Latest_version}" ]; then
  #env传参
  echo "- 可更新构建"
  echo "new_version=yes" >> ${GITHUB_ENV}
  echo "ReleaseVersion=${Latest_version}" >> ${GITHUB_ENV}
else
  echo "- 暂无新版更新"
fi

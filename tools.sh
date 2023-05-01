dl_gh() {
    echo "⏬ Downloading resources..."
    for repo in revanced-patches revanced-cli revanced-integrations ; do
    asset_urls=$(wget -qO- "https://api.github.com/repos/revanced/$repo/releases/latest" | jq -r '.assets[] | "\(.browser_download_url) \(.name)"')
        while read -r url names
        do
            echo "Downloading $names from $url"
            wget -q -O "$names" $url
        done <<< "$asset_urls"
    done

echo "All assets downloaded"
}
get_patches_key() {
EXCLUDE_PATCHES=()
for word in $(cat $1/exclude-patches) ; do
    EXCLUDE_PATCHES+=("-e $word")
done
INCLUDE_PATCHES=()
for word in $(cat $1/include-patches) ; do
    INCLUDE_PATCHES+=("-i $word")
done
}
# Function download YouTube and YouTube Music apk from APKmirror
req() { 
    wget -nv -O "$2" -U "Mozilla/5.0 (X11; Linux x86_64; rv:111.0) Gecko/20100101 Firefox/111.0" "$1"
}
# Wget apk verions
get_apk_vers() { req "$1" - | sed -n 's;.*Version:</span><span class="infoSlide-value">\(.*\) </span>.*;\1;p'; }

# Wget apk verions(largest)
get_largest_ver() {
	local max=0
	while read -r v || [ -n "$v" ]; do
		if [[ ${v//[!0-9]/} -gt ${max//[!0-9]/} ]]; then max=$v; fi
	done
	if [[ $max = 0 ]]; then echo ""; else echo "$max"; fi
}

dl_apk() {
	local url=$1 regexp=$2 output=$3
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n "s/href=\"/@/g; s;.*${regexp}.*;\1;p")"
	echo "$url"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$output"
}

# Downloading youtube
dl_yt() {
	echo "Downloading YouTube"
	local last_ver
	last_ver="$ytversion"
	last_ver="${last_ver:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=youtube" | get_largest_ver)}"
	
	echo "Choosing version '${last_ver}'"
	local base_apk="youtube-v$ytversion.apk"
	  dl_url=$(dl_apk "https://www.apkmirror.com/apk/google-inc/youtube/youtube-${last_ver//./-}-release/" \
			"APK</span>[^@]*@\([^#]*\)" \
			"$base_apk")
		echo "YouTube version: ${last_ver}"
		echo "downloaded from: [APKMirror - YouTube]($dl_url)"
}

# Downloading youtube music
dl_ytms() {
	echo "Downloading YouTube Music (${arm64-v8a})"
	local last_ver
	last_ver="$ytmsversion"
	last_ver="${last_ver:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=youtube-music" | get_largest_ver)}"
	
	echo "Choosing version '${last_ver}'"
	local base_apk="youtube-music.apk"
	local regexp_arch='arm64-v8a</div>[^@]*@\([^"]*\)'
		dl_url=$(dl_apk "https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-${last_ver//./-}-release/" \
			"$regexp_arch" \
			"$base_apk")
		echo "YouTube Music (${arm64-v8a}) version: ${last_ver}"
		echo "downloaded from: [APKMirror - YouTube Music ${arm64-v8a}]($dl_url)"
}
# Downloading tiktok
dl_tt() {
	echo "Downloading TikTok"
	local last_ver
	last_ver="$ttversion"
	last_ver="${last_ver:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=tik-tok-including-musical-ly" | get_largest_ver)}"
	
	echo "Choosing version '${last_ver}'"
	local base_apk="tiktok.apk"
		dl_url=$(dl_apk "https://www.apkmirror.com/apk/tiktok-pte-ltd/tik-tok-including-musical-ly/tik-tok-including-musical-ly-${last_ver//./-}-release/" \
			"APK</span>[^@]*@\([^#]*\)" \
			"$base_apk")
		echo "TikTok version: ${last_ver}"
		echo "downloaded from: [APKMirror - TikTok]($dl_url)"
}

# Downloading twitch
dl_twitch() {
	echo "Downloading Twitch"
	local last_ver
	last_ver="$twversion"
	last_ver="${last_ver:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=twitch" | get_largest_ver)}"

	echo "Choosing version '${last_ver}'"
	local base_apk="twitch.apk"
		dl_url=$(dl_apk "https://www.apkmirror.com/apk/twitch-interactive-inc/twitch/twitch-${last_ver//./-}-release/" \
			"APK</span>[^@]*@\([^#]*\)" \
			"$base_apk")
		echo "Twitch version: ${last_ver}"
		echo "downloaded from: [APKMirror - Twitch]($dl_url)"
}
dl_mes() {
	echo "Downloading Messenger (${arm64-v8a})"
	local last_ver
	last_ver="$version"
	last_ver="${last_ver:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=messenger" | get_largest_ver)}"
	
	echo "Choosing version '${last_ver}'"
	local base_apk="messenger.apk"
	local regexp_arch='arm64-v8a</div>[^@]*@\([^"]*\)'
		dl_url=$(dl_apk "https://www.apkmirror.com/apk/facebook-2/messenger/messenger-${last_ver//./-}-release/" \
			"$regexp_arch" \
			"$base_apk")
		echo "Messenger (${arm64-v8a}) version: ${last_ver}"
		echo "downloaded from: [APKMirror - Messenger ${arm64-v8a}]($dl_url)"
}
# Function fletch latest supported version can patch
get_support_ytversion() {
    ytversion=$(jq -r '.[] | select(.name == "microg-support") | .compatiblePackages[] | select(.name == "com.google.android.youtube") | .versions[-1]' patches.json) 
    echo "✅️ Found version: $ytversion"
}
get_support_ytmsversion() {
    ytmsversion=$(jq -r '.[] | select(.name == "hide-get-premium") | .compatiblePackages[] | select(.name == "com.google.android.apps.youtube.music") | .versions[-1]' patches.json)
    echo "✅️ Found version: $ytmsversion"
}
get_tw_ver() {
twversion=$(jq -r '.[] | select(.name == "block-video-ads") | .compatiblePackages[] | select(.name == "tv.twitch.android.app") | .versions[-1]' patches.json)
}
get_tt_ver() {
ttversion=$(jq -r '.[] | select(.name == "sim-spoof") | .compatiblePackages[] | select(.name == "com.ss.android.ugc.trill") | .versions[-1]' patches.json)
}
patch() {
if [ -f "$1.apk" ]; then
java -jar revanced-cli*.jar -m revanced-integrations*.apk -b revanced-patches*.jar -a $1.apk ${EXCLUDE_PATCHES[@]} ${INCLUDE_PATCHES[@]} --keystore=ks.keystore -o ./build/$2.apk
else 
exit 1
}
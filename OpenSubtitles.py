import json
import urllib
import urllib.request
import subprocess


class OpenSubtitles:
    BASE_URL = "https://api.opensubtitles.com/api/v1"
    HASH_BINARY_PATH = "/var/packages/VideoStation/target/bin/video_hash"
    INFO_PATH = (
        "/var/packages/VideoStation/target/subtitle_plugins/syno_opensubtitles/INFO"
    )
    token = ""
    apikey = ""
    plugin_version = "0.0"

    def __init__(self, user, password, apikey):
        self.apikey = apikey
        self.login_and_set_token(user, password)

        with open(self.INFO_PATH, "r") as f:
            self.plugin_version = json.load(f)["version"]

    def __query(self, url, method="GET", data=None):
        result = None
        timeouts = 30

        header = {
            "User-Agent": f"Videostation_Opensubtitles_Plugin v{self.plugin_version}",
            "Accept": "application/json",
        }

        if self.token:
            header["Authorization"] = f"Bearer {self.token}"
        if self.apikey:
            header["Api-Key"] = self.apikey

        try:
            data_encoded = None
            if data:
                data_encoded = urllib.parse.urlencode(data).encode("ascii")

            request = urllib.request.Request(
                url=url, headers=header, data=data_encoded, method=method
            )
            response = urllib.request.urlopen(request, timeout=timeouts)
            result = response.read().decode("utf-8")

        except urllib.error.HTTPError as http_e:
            print("http error:", http_e)

        except Exception as e:
            print("exception", e)

        return result

    def __get_size_and_hash(self, file_path):
        execute_array = [self.HASH_BINARY_PATH, "--opensubtitles", file_path]
        p = subprocess.Popen(
            execute_array, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        out, err = p.communicate()

        if err:
            return False

        response_string = str(out, "utf-8")
        return json.loads(response_string)

    def login_and_set_token(self, user, password):
        url = f"{self.BASE_URL}/login"
        data = {"username": user, "password": password}
        login_result = self.__query(url=url, method="POST", data=data)
        self.token = json.loads(login_result)["token"]

    def search_subtitle_by_file_hash(self, path, lang):
        info = self.__get_size_and_hash(path)
        return self.__search_subtitle_by_hash(info["hash"], lang)

    def __search_subtitle_by_hash(self, hash, lang):
        url = f"{self.BASE_URL}/subtitles?moviehash={hash}&languages={lang}"
        result = self.__query(url=url, method="GET")
        return json.loads(result)

    def search_subtitle_by_feature_id(self, id, lang):
        url = f"{self.BASE_URL}/subtitles?id={id}&languages={lang}"
        result = self.__query(url=url, method="GET")
        return json.loads(result)

    def search_feature_by_title(self, title):
        titleEncode = urllib.parse.quote_plus(title.lower())
        url = f"{self.BASE_URL}/features?query={titleEncode}"
        result = self.__query(url=url, method="GET")
        return json.loads(result)

    def run_download(self, site_subtitle_id, save_file_Path):
        link = self.__get__download_link(site_subtitle_id)
        self.__download_link(link, save_file_Path)

    def __get__download_link(self, fileId):
        url = f"{self.BASE_URL}/download"
        data = {"file_id": fileId}
        result = self.__query(url=url, method="POST", data=data)
        return json.loads(result)["link"]

    def __download_link(self, link, save_file_Path):
        result = self.__query(url=link, method="GET")

        with open(save_file_Path, "w", encoding="utf-8") as f:
            if not result:
                result = ""
            f.write(result)

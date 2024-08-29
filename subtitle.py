import os
import json
import argparse
import OpenSubtitles
import html
import Language


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--action", type=str, required=True, help="search|download")
    parser.add_argument(
        "--path",
        type=str,
        default="",
        help="search by file path, would be useless when set title",
    )
    parser.add_argument(
        "--title",
        type=str,
        default="",
        help="search by title, prior than search by path",
    )
    parser.add_argument("--id", type=str, default="", help="download id")
    parser.add_argument(
        "--lang", type=str, default="eng", help="search language, ex: eng or eng,fre"
    )
    parser.add_argument(
        "--limit", type=int, default=10, help="search limit, default 10"
    )
    parser.add_argument("--username", type=str, required=True)
    parser.add_argument("--password", type=str, default="")
    parser.add_argument("--apikey", type=str, default="")

    args = parser.parse_known_args()[0]

    username = args.username
    password = args.password
    apikey = args.apikey

    if not password:
        password = os.environ["SUBTITLE_PLUGIN_PASSWORD"]
    if not apikey:
        apikey = os.environ["SUBTITLE_PLUGIN_APIKEY"]

    site = OpenSubtitles.OpenSubtitles(username, password, apikey)
    action = args.action
    lang = Language.convert_language_code_639_2B_to_639_1(args.lang)
    if not lang:
        lang = "en"
    path = args.path
    title = args.title
    limit = args.limit

    if action == "search":
        items = do_search(site, title, lang, path, limit)

        process_output({"items": items, "total": len(items)})

    elif action == "download":
        id = args.id
        save_file_path = do_download(site, id, path)

        process_output({"id": save_file_path})

    else:
        parser.print_help()


def do_search(site, title, lang, path, limit):
    items = []
    if title != "":
        searchFeatureResult = site.search_feature_by_title(title)
        if searchFeatureResult["data"]:
            feature_id = searchFeatureResult["data"][0]["id"]
            search_subtitle_result = site.search_subtitle_by_feature_id(
                feature_id, lang
            )
            items = transform_search_subtitle_result(
                search_subtitle_result, path, limit
            )
    else:
        search_subtitle_result = site.search_subtitle_by_file_hash(path, lang)
        items = transform_search_subtitle_result(search_subtitle_result, path, limit)

        if len(items) == 0:
            base_name = os.path.basename(path)
            file_name = os.path.splitext(base_name)[0]
            searchFeatureResult = site.search_feature_by_title(file_name)

            if searchFeatureResult["data"]:
                feature_id = searchFeatureResult["data"][0]["id"]
                search_subtitle_result = site.search_subtitle_by_feature_id(
                    feature_id, lang
                )
                items = transform_search_subtitle_result(
                    search_subtitle_result, path, limit
                )
    return items


def do_download(site, id, path):
    directory = os.path.dirname(path)
    save_file_path = f"{directory}/{id}.srt"

    language_id, site_subtitle_id = decompose_id(id)
    site.run_download(site_subtitle_id, save_file_path)
    return save_file_path


def get_subtitle_full_path(prefix):
    dirname = os.path.dirname(prefix)
    files = [f for f in os.listdir(dirname) if os.path.isfile(os.path.join(dirname, f))]
    for f in files:
        filename = os.path.join(dirname, f)
        if 0 == filename.find(prefix):
            return filename
    return False


def compose_id(file_name, language_id, site_subtitle_id):
    return f"{file_name}.{language_id}.{site_subtitle_id}"


def decompose_id(id):
    split_result = id.split(".")
    site_subtitle_id = split_result[len(split_result) - 1]
    language_id = split_result[len(split_result) - 2]
    return language_id, site_subtitle_id


def transform_search_subtitle_result(search_subtitle_result, file_path, limit):
    items = []
    for data in search_subtitle_result["data"]:
        site_subtitle_id = data["id"]
        language_id = data["attributes"]["language"].lower()
        base_name = os.path.basename(file_path)
        file_name = os.path.splitext(base_name)[0]
        file_directory = os.path.dirname(file_path)

        id = compose_id(file_name, language_id, site_subtitle_id)

        prefix = f"{file_directory}/{id}"

        subtitle_id = get_subtitle_full_path(prefix)

        item = {
            "id": id,
            "downloaded": bool(subtitle_id),
            "filename": data["attributes"]["release"],
            "language": Language.get_language_name(language_id),
            "language_id": language_id,
            "plugin_id": "com.synology.OpenSubtitles",
            "plugin_title": "OpenSubtitles",
            "subtitle_id": subtitle_id,
        }
        items.append(item)
        if limit > 0 and len(items) >= limit:
            break
    return items


def process_output(output):
    json_string = json.dumps(output, ensure_ascii=False, separators=(",", ":"))
    json_string = html.unescape(json_string)
    print(json_string)


if __name__ == "__main__":
    main()
    exit(0)

# get from api https://api.opensubtitles.com/api/v1/infos/languages
_LANGUAGE_CODE_TO_NAME_MAPPING = {
    "af": "Afrikaans",
    "sq": "Albanian",
    "ar": "Arabic",
    "an": "Aragonese",
    "hy": "Armenian",
    "at": "Asturian",
    "eu": "Basque",
    "be": "Belarusian",
    "bn": "Bengali",
    "bs": "Bosnian",
    "br": "Breton",
    "bg": "Bulgarian",
    "my": "Burmese",
    "ca": "Catalan",
    "zh-cn": "Chinese (simplified)",
    "cs": "Czech",
    "da": "Danish",
    "nl": "Dutch",
    "en": "English",
    "eo": "Esperanto",
    "et": "Estonian",
    "fi": "Finnish",
    "fr": "French",
    "ka": "Georgian",
    "de": "German",
    "gl": "Galician",
    "el": "Greek",
    "he": "Hebrew",
    "hi": "Hindi",
    "hr": "Croatian",
    "hu": "Hungarian",
    "is": "Icelandic",
    "id": "Indonesian",
    "it": "Italian",
    "ja": "Japanese",
    "kk": "Kazakh",
    "km": "Khmer",
    "ko": "Korean",
    "lv": "Latvian",
    "lt": "Lithuanian",
    "lb": "Luxembourgish",
    "mk": "Macedonian",
    "ml": "Malayalam",
    "ms": "Malay",
    "ma": "Manipuri",
    "mn": "Mongolian",
    "no": "Norwegian",
    "oc": "Occitan",
    "fa": "Persian",
    "pl": "Polish",
    "pt-pt": "Portuguese",
    "ru": "Russian",
    "sr": "Serbian",
    "si": "Sinhalese",
    "sk": "Slovak",
    "sl": "Slovenian",
    "es": "Spanish",
    "sw": "Swahili",
    "sv": "Swedish",
    "sy": "Syriac",
    "ta": "Tamil",
    "te": "Telugu",
    "tl": "Tagalog",
    "th": "Thai",
    "tr": "Turkish",
    "uk": "Ukrainian",
    "ur": "Urdu",
    "uz": "Uzbek",
    "vi": "Vietnamese",
    "ro": "Romanian",
    "pt-br": "Portuguese (Brazilian)",
    "me": "Montenegrin",
    "zh-tw": "Chinese (traditional)",
    "ze": "Chinese bilingual",
    "nb": "Norwegian Bokmal",
    "se": "Northern Sami",
}

# opensubtitles language setting mapping
# see SYNO.SDS.VideoStation2.Setting.AdvancedPanel.SubtitleSet.LANGUAGE_MAPPING
# and SYNO.SDS.VideoStation2.Setting.AdvancedPanel.SubtitleSet.EXTRA_LANGUAGE
_VS_OPENSUBTITLES_LANGUAGE_SETTING_MAPPING = {
    "cze": "cs",
    "dan": "da",
    "eng": "en",
    "fre": "fr",
    "ger": "de",
    "hun": "hu",
    "ita": "it",
    "jpn": "ja",
    "kor": "ko",
    "dut": "nl",
    "nor": "no",
    "pol": "pl",
    "pob": "pt-br",
    "por": "pt-pt",
    "rus": "ru",
    "spa": "es",
    "swe": "sv",
    "tha": "th",
    "tur": "tk",
    "chi": "zh-cn",
    "fin": "fi",
    "ara": "ar",
    "heb": "he",
    "ell": "el",
    "rum": "ro",
    "scc": "sr",
    "hrv": "hr",
    "bul": "bg",
    "slv": "sl",
    "bos": "bs",
}


def get_language_name(language_code):
    if language_code in _LANGUAGE_CODE_TO_NAME_MAPPING:
        return _LANGUAGE_CODE_TO_NAME_MAPPING[language_code]
    return language_code


def convert_language_code_639_2B_to_639_1(language_code):
    language_list = language_code.split(",")
    converted_language_list = []
    for lang in language_list:
        if lang in _VS_OPENSUBTITLES_LANGUAGE_SETTING_MAPPING:
            converted_language_list.append(
                _VS_OPENSUBTITLES_LANGUAGE_SETTING_MAPPING[lang]
            )

    return ",".join(converted_language_list)

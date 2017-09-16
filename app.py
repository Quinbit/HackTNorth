from googletrans import Translator
import json
import ast
from operator import itemgetter
from os.path import join, dirname
from os import environ
from watson_developer_cloud import VisualRecognitionV3

def func(language, cutoff_score, entries_to_keep, imageUrl):

    # Define packages
    translator = Translator()
    visual_recognition = VisualRecognitionV3('2016-05-20', api_key='9a7a0b69bd17b6170aea8d075a67a431b1890107')

    # Raw response data as string
    response = json.dumps(visual_recognition.classify(images_url=imageUrl), indent=2)

    # Stripped response data with classes
    array = ast.literal_eval(response).get('images', 0)[0].get('classifiers', 1)[0].get('classes', 2)

    # Classes ordered by score (highest first)
    ordered = sorted(array, key=itemgetter('score'), reverse = True)

    # Only keep classes with scores higher than cutoff_score
    filtered = [it for it in ordered if it['score'] > cutoff_score]

    # Only keep top entries_to_keep entries
    top = filtered[:entries_to_keep]

    # List of all expressions in English
    eng = [expression['class'] for expression in top]

    # List of all translated objects
    translated = translator.translate(eng, dest=language)

    # return translated text + pronunciation for all relevant entries
    return [[str(i.text), str(i.pronunciation)] for i in translated]
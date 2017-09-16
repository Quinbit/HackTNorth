from googletrans import Translator
import json
from os.path import join, dirname
from os import environ
from watson_developer_cloud import VisualRecognitionV3

translator = Translator()

res = translator.translate('안녕하세요.')

visual_recognition = VisualRecognitionV3('2016-05-20', api_key='9a7a0b69bd17b6170aea8d075a67a431b1890107')

print(json.dumps(visual_recognition.classify(images_url=https://www.ibm.com/ibm/ginni/images/ginni_bio_780x981_v4_03162016.jpg), indent=2)
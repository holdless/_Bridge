# <nltk using stanford pos-tagging model:>
# 1.for nltk, set environment variable is very important to call stanford nlp model
#   https://github.com/nltk/nltk/wiki/Installing-Third-Party-Software
# 2.and if the stanford pos-tagger version >= 2015-12-09, all .jar files in the "lib" directory should be pointed in the CLASSPATH
# 3.check these 2 websites for example code:
#   http://www.nltk.org/_modules/nltk/tag/stanford.html
#   http://www.nltk.org/api/nltk.tag.html#module-nltk.tag.stanford
#
import os
java_path = "D:/Program Files/Java/jre1.8.0_66/bin/java.exe"
os.environ['JAVAHOME'] = java_path

#from nltk.tag import StanfordNERTagger
#st = StanfordNERTagger('english.all.3class.distsim.crf.ser')
#st.tag('Rami Eid is studying at Stony Brook University in NY'.split())

from nltk.tag import StanfordPOSTagger
st = StanfordPOSTagger('english-left3words-distsim.tagger') # doctest: +SKIP
st.tag('What is the airspeed of an unladen swallow ?'.split()) # doctest: +SKIP


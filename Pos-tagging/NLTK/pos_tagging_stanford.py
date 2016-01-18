# 
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


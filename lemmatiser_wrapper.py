import sys
import nltk
from nltk.corpus import wordnet
from nltk.stem import WordNetLemmatizer
punc_list = '''!()-[]{};:'"\,<>./?@#$%^&*_~'''

def tagged_word(l):
    
    word = nltk.pos_tag([l])[0][1][0].upper()
    tag_dict = {"N": wordnet.NOUN, "J": wordnet.ADJ, "V": wordnet.VERB, "R": wordnet.ADV}

    return tag_dict.get(word)

def lematize(l):
    
    no_punct = ""
    for i in l:
        if i not in punc_list:
            no_punct += i
            l = no_punct
    lematizer = WordNetLemmatizer()
    l = l.casefold()	
    term = ' '.join([lematizer.lemmatize(w, tagged_word(w)) for w in l.split()])
    return term    

def evaluate():

    w = ""
    for i in range(1, len(sys.argv)):
        w += sys.argv[i] + " "
    print(lematize(w))    

if __name__ == "__main__":
    evaluate()


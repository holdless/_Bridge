/*
 add jar files:
1. stanford-parser.jar
2. slf4j-api.jar
3. slf4j-simple.jar
4. stanford-parser-3.6.0-models.jar
 */
package letstalk;

//import java.io.IOException;
import edu.stanford.nlp.tagger.maxent.MaxentTagger;
import java.util.Arrays;

//import java.util.Collection;
import java.util.List;
//import java.io.StringReader;

//import edu.stanford.nlp.process.Tokenizer;
//import edu.stanford.nlp.process.TokenizerFactory;
//import edu.stanford.nlp.process.CoreLabelTokenFactory;
//import edu.stanford.nlp.process.DocumentPreprocessor;
//import edu.stanford.nlp.process.PTBTokenizer;
import edu.stanford.nlp.ling.CoreLabel;
//import edu.stanford.nlp.ling.HasWord;
import edu.stanford.nlp.ling.Sentence;
import edu.stanford.nlp.trees.*;
import edu.stanford.nlp.parser.lexparser.LexicalizedParser;
import java.util.ArrayList;

public class LetsTalk {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        /////////
        /////// 
        // input voice: usually from RPi mic
//        String rawSentence = "tango would you please light on the candle before Jane comes back";
//        String rawSentence = "tango turn on the light for marry before sunrise and tell me where am i";
        String rawSentence = "tango tell me what's wrong with you and where are you";
//        String rawSentence = "tango open the door which is in front of the chair for marry before sunrise and tell me where i am";
        ///////
        ////////

        // make sure all chars to lower-case
        String lowerCaseSentence = rawSentence.toLowerCase();
        // make sure "I" remains capitalized
        if (lowerCaseSentence.contains(" i "))
            lowerCaseSentence = lowerCaseSentence.replace(" i ", " I ");
        else if (lowerCaseSentence.contains(" i"))
            lowerCaseSentence = lowerCaseSentence.replace(" i", " I");
        else if (lowerCaseSentence.contains("i "))
            lowerCaseSentence = lowerCaseSentence.replace("i", "I ");

        System.out.println("original sentence: " + rawSentence);

        // check if the input voice is "to Robot" or not
        int fromIndex = 0;
        boolean __talkToRobot = false;
        String ROBOT_NAME = "tango";
        if (lowerCaseSentence.contains(ROBOT_NAME)) {
            fromIndex = lowerCaseSentence.indexOf(ROBOT_NAME) + ROBOT_NAME.length() + 1;
//            System.out.println("index is: " + fromIndex);
            __talkToRobot = true;
        }

        //////////////////////////////////////////////////////////////////////////
        // if the the voice is "to Robot", then do the following NLP /////////////
        //////////////////////////////////////////////////////////////////////////
        if (__talkToRobot) {
            // path of stanford pos-tagger, parser
            String taggerModel = "/Users/hiroshi/x/__stanford_nlp/stanford-postagger-2015-12-09/models/english-left3words-distsim.tagger";
            String parserModel = "edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz";

            //// init: 1) stanford tagger, 2) parser
            System.out.println("\n---- init pos-tagger & parser -----");
            MaxentTagger myTagger = initTagger(taggerModel);
            LexicalizedParser lp = initParser(parserModel);

            //// "lowercase" transformation
            String sent = lowerCaseSentence.substring(fromIndex);

            //// "smash" prefix
            System.out.println("\n---- smash prefix -----");
            String extractedSent = smashPrefix(sent);
            System.out.println(extractedSent);

            //// "parsing phrase"
            System.out.println("\n---- start parsing phrase -----");
            layerOneParse(lp, myTagger, extractedSent);

            /*            //// syntax analysis
            System.out.println("\n---- syntax analyzing -----");
            int a = syntaxAnalysis(fully_separate, individual_word.length);
             */
        }
    }

    //////////////////////////////////////////////////////////////////////////////
    // init stanford pos-tagger
    public static MaxentTagger initTagger(String path) {
        // Initialize the tagger
        MaxentTagger tagger = new MaxentTagger(path);
        return tagger;
    }

    // init stanford parser
    public static LexicalizedParser initParser(String path) {
        return LexicalizedParser.loadModel(path);
    }

    /**
     * demoAPI demonstrates other ways of calling the parser with already
     * tokenized text, or in some cases, raw text that needs to be tokenized as
     * a single sentence. Output is handled with a TreePrint object. Note that
     * the options used when creating the TreePrint can determine what results
     * to print out. Once again, one can capture the output by passing a
     * PrintWriter to TreePrint.printTree. This code is for English.
     *
     * @param lp: lexicalized parser
     * @param sentence: extracted sentence
     */
    public static void layerOneParse(LexicalizedParser lp, MaxentTagger tagger, String sentence) {
        // This option shows parsing a list of correctly tokenized words
        Tree parse = createParseTree(lp, sentence);
        // Clause: SBAR/SBARQ/SINV(SQ) + VP
        // SINV: inverted 
        // SBARQ: wh-
        ArrayList<Integer> depthCC = new ArrayList<>();
        ArrayList<String> sCC = new ArrayList<>();

        ArrayList<String> clauseCandidate = new ArrayList<>();
        ArrayList<Integer> clauseCandidateDepth = new ArrayList<>();
        ArrayList<String> clause = new ArrayList<>();
        ArrayList<Integer> clauseDepth = new ArrayList<>();

        // parsing tree...
        for (Tree A : parse) {
//            System.out.println(A.isLeaf());
//            System.out.println(A.isPhrasal());
            if (A.label().value().equals("CC")) {
                depthCC.add(parse.depth(A));
                sCC.add(setClause(A));
            }
            if (A.label().value().equals("SBAR")
                    || A.label().value().equals("SBARQ")
                    || A.label().value().equals("SINV")
                    || A.label().value().equals("VP")) {
                clauseCandidateDepth.add(parse.depth(A));
                clauseCandidate.add(setClause(A));
            }
        }

        if (!depthCC.isEmpty()) {
            for (int i = 0; i < depthCC.size(); i++) {
                if (i > 0 && depthCC.get(i).equals(depthCC.get(0))) {
                    break;
                }

                for (int j = 0; j < clauseCandidateDepth.size(); j++) {
                    if (clauseCandidateDepth.get(j).equals(depthCC.get(i))) {
                        clause.add(clauseCandidate.get(j));
                        clauseDepth.add(clauseCandidateDepth.get(j));
                    }
                }
            }
        } else {
            int index = 0;
            for (int i = 1; i < clauseCandidateDepth.size(); i++) {
                if (clauseCandidateDepth.get(i) < clauseCandidateDepth.get(0)) {
                    index = i;
                }
            }
            clause.add(clauseCandidate.get(index));
            clauseDepth.add(clauseCandidateDepth.get(index));
        }

        // display clauses...
        for (int i = 0; i < clause.size(); i++) {
            System.out.print("depth:" + clauseDepth.get(i));
            System.out.println(">>" + clause.get(i));
            //613.4.0324 hiroshi: test "parseKeyPhrase" here. should be put in main block later...
            layerTwoParse(lp, tagger, clause.get(i));
        }
        for (int i = 0; i < depthCC.size(); i++) {
            System.out.print("depth:" + depthCC.get(i));
            System.out.println(">>CC: " + sCC.get(i));
        }

    }

    // most for smash "sub-clause" prefix purpose
    public static void layerTwoParse(LexicalizedParser lp, MaxentTagger tagger, String clause) {
        // smash prefix of parsed clauses...
        String extractedClause = smashPrefix(clause);

        Tree parse = createParseTree(lp, extractedClause);
        String[] subClause = new String[2];
        boolean toBreak = false;
        
        subClause[0] = clause;
        subClause[1] = "UNSORT";

        for (Tree A : parse) {
//            System.out.println(A.isLeaf());
//            System.out.println(A.isPhrasal());
            if (toBreak)
                break;
            
            switch (A.label().value()) {
                case "SBARQ":
                    subClause[0] = setClause(A);
                    subClause[1] = "SBARQ";
                    System.out.println(subClause[1] + ":" + subClause[0]);
                    toBreak = true;
                    break;
                case "SINV":
                    subClause[0] = setClause(A);
                    subClause[1] = "SINV";
                    System.out.println(subClause[1] + ":" + subClause[0]);
                    toBreak = true;
                    break;
                case "VP":
                    subClause[0] = setClause(A);
                    subClause[1] = "VP";
                    System.out.println(subClause[1] + ":" + subClause[0]);
                    toBreak = true;
                    break;
            }
        }

        layerThreeParse(lp, tagger, subClause);
    }

    public static void layerThreeParse(LexicalizedParser lp,
            MaxentTagger tagger,
            String[] clause) {
        // pos-tagging first
        String[][] wordTagArray = tag(tagger, clause[0]);
        String wh_key = "wh_key";
        String v_key = "v_key";
        String n_key = "n_key";
        String prp_key = "prp_key";
        String j_key = "j_key";

        for (int i = 0; i < wordTagArray.length; i++) {
            if (wordTagArray[i][1].contains("W")) {
                System.out.println("WH-key: '" + wordTagArray[i][0] + "' on index " + i);
                wh_key = wordTagArray[i][0];
            }
            if (wordTagArray[i][1].contains("V")) {
                System.out.println("V-key: '" + wordTagArray[i][0] + "' on index " + i);
                v_key = wordTagArray[i][0];
            }
            if (wordTagArray[i][1].contains("NN")) {
                System.out.println("N-key: '" + wordTagArray[i][0] + "' on index " + i);
                v_key = wordTagArray[i][0];
            }
            if (wordTagArray[i][1].contains("PRP")) {
                System.out.println("PRP-key: '" + wordTagArray[i][0] + "' on index " + i);
                prp_key = wordTagArray[i][0];
            }
            if (wordTagArray[i][1].contains("JJ")) {
                System.out.println("N-key: '" + wordTagArray[i][0] + "' on index " + i);
                v_key = wordTagArray[i][0];
            }
        }

        // second, parse again...
        Tree parse = createParseTree(lp, clause[0]);
        String[] subClause = new String[2];

        switch (clause[1]) {
            case "SBARQ": 
                /// hiroshi 613.6.0326@sunset-corner: add "question conditons"  
                boolean toBreak = false;
                for (Tree A : parse) {
                    if (toBreak)
                        break;
                    switch (A.label().value()) {
                        case "WHADJP":
                            subClause[0] = setClause(A);
                            subClause[1] = "WHADJP";
                            System.out.println(subClause[1] + ":" + subClause[0]);
                            toBreak = true;
                            // question like: how hot --> searh j_key/n_key/prp_key
                            System.out.println("describe(google): " + n_key + "," + prp_key + "with adj: " + j_key);
                            break;
                        case "WHADVP":
                            subClause[0] = setClause(A);
                            subClause[1] = "WHADVP";
                            System.out.println(subClause[1] + ":" + subClause[0]);
                            toBreak = true;
                            // question like: where --> searh n_key + google map
                            System.out.println("google map: " + n_key + "," + prp_key);
                            break;
                        case "WHNP":
                            subClause[0] = setClause(A);
                            subClause[1] = "WHNP";
                            System.out.println(subClause[1] + ":" + subClause[0]);
                            toBreak = true;
                            break;
                        case "WHPP":
                            subClause[0] = setClause(A);
                            subClause[1] = "WHPP";
                            System.out.println(subClause[1] + ":" + subClause[0]);
                            toBreak = true;
                            break;
                        default:
                            subClause[0] = "?";
                            subClause[1] = "?";
                            break;
                    }
                }
                break;
            
            case "SINV": 
                break;
       
            case "VP": 
                break;
                
            case "UNSORT":
                break;
        }

    }

    public static Tree createParseTree(LexicalizedParser lp, String sentence) {
        String[] sent = sentence.split(" ");
//        String[] sent = { "This", "is", "an", "easy", "sentence", "." };
        List<CoreLabel> rawWords = Sentence.toCoreLabelList(sent);
        Tree parse = lp.apply(rawWords);
        parse.pennPrint();
        System.out.println();

        return parse;
    }

    public static String setClause(Tree A) {
        String subClause;
        String aa = A.yieldWords().toString();
        subClause = (aa.substring(1, aa.length() - 1).replace(",", ""));
        return subClause;
    }

    // smash prefix
    public static String smashPrefix(String lowerCaseSentence) {
        int fromIndex = 0;
        int toIndex = lowerCaseSentence.length();
        //// unnecessary words elimination...
        // stage 1: "would you" rule
        if (lowerCaseSentence.contains("would you")
                || lowerCaseSentence.contains("could you")
                || lowerCaseSentence.contains("can you")) {
            fromIndex = lowerCaseSentence.indexOf("you") + "you".length() + 1;
            // "please" rule: "please/mind" follow "would you"
            if (lowerCaseSentence.substring(fromIndex, fromIndex + "please".length()).equals("please")) {
                fromIndex = fromIndex + "please".length() + 1;
            } else if (lowerCaseSentence.substring(fromIndex, fromIndex + "mind".length()).equals("mind")) {
                fromIndex = fromIndex + "mind".length() + 1;
            }

            // "tell me/help me" rule
            if (lowerCaseSentence.substring(fromIndex, fromIndex + "tell me".length()).equals("tell me")) {
                fromIndex = fromIndex + "tell me".length() + 1;
            } else if (lowerCaseSentence.substring(fromIndex, fromIndex + "help me".length()).equals("help me")) {
                fromIndex = fromIndex + "help me".length() + 1;
            }

//            System.out.println("index is: " + fromIndex);
        } // stage 1: "help me" rule
        else if (lowerCaseSentence.contains("help me") && lowerCaseSentence.indexOf("help") == 0) {
            fromIndex = "help me".length() + 1;
//            System.out.println("index is: " + fromIndex);
        } // stage 1: "tell me" rule
        else if (lowerCaseSentence.contains("tell me") && lowerCaseSentence.indexOf("tell") == 0) {
            fromIndex = "tell me".length() + 1;
//            System.out.println("index is: " + fromIndex);
        } // stage 1: "how about" rule
        else if (lowerCaseSentence.contains("how about") && lowerCaseSentence.indexOf("how") == 0) {
            fromIndex = "how about".length() + 1;
//            System.out.println("index is: " + fromIndex);
        } // stage 1: "would you mind" rule
        else if (lowerCaseSentence.contains("would you mind") && lowerCaseSentence.indexOf("would") == 0) {
            fromIndex = "would you mind".length() + 1;
//            System.out.println("index is: " + fromIndex);
        } // stage 1: "let's" rule
        else if (lowerCaseSentence.contains("let's") && lowerCaseSentence.indexOf("let's") == 0) {
            fromIndex = "let's".length() + 1;
//            System.out.println("index is: " + fromIndex);
        } // stage 1: "...think about" rule
        else if (lowerCaseSentence.contains("think about") && lowerCaseSentence.indexOf("think") == 0) {
            fromIndex = lowerCaseSentence.indexOf("think about") + "think about".length() + 1;
//            System.out.println("index is: " + fromIndex);
        } // stage 1: "do you know" rule
        else if (lowerCaseSentence.contains("do you know") && lowerCaseSentence.indexOf("do") == 0) {
            fromIndex = "do you know".length() + 1;
//            System.out.println("index is: " + fromIndex);
        }

        // stage 2: "Start/end pleae" rule
        if (lowerCaseSentence.contains("please")) {
            if (lowerCaseSentence.indexOf("please") == 0) {
                fromIndex = "please".length() + 1;
            }
            if (lowerCaseSentence.indexOf("please") + "please".length() == lowerCaseSentence.length()) {
                toIndex = toIndex - "please".length();
            }

//            System.out.println("index is: " + fromIndex);
        }

        String extractedSentence = lowerCaseSentence.substring(fromIndex, toIndex);
        return extractedSentence;
    }

    // tag extracted sentence
    public static String[][] tag(MaxentTagger tagger, String extractedSentence) {
        // stage 3: pos-tagging
        // The tagged string
        String tagged_str = tagger.tagString(extractedSentence);

        // output the tagged sentence
//        System.out.println(tagged_str);
        // acuire the separated word-tag array (nx2)
        String[] individual_word = tagged_str.split(" ");
        String[][] wordTagArray = new String[individual_word.length][2];

        for (int i = 0; i < individual_word.length; i++) {
            wordTagArray[i] = individual_word[i].split("_");
//            System.out.println(Arrays.toString(fully_separate[i]));
        }

        return wordTagArray;
    }

    // after tags acquired, do syntax analysis: understand meaning and execute order
    public static int syntaxAnalysis(String[][] fully_separate, int sentenceLength) {
        int vpFromIndex = 0;
        int vpToIndex = sentenceLength;
        // start syntax analysis: sorting by key.
        for (int i = 0; i < sentenceLength; i++) {
            if (fully_separate[i][1].contains("W")) {
                System.out.println("WH-key: '" + fully_separate[i][0] + "' on index " + i);
            }

            // find the verb-phrase
            // find the verb
            if (fully_separate[i][1].contains("V")) {
                vpFromIndex = i;
                System.out.println("V-key: '" + fully_separate[i][0] + "' on index " + vpFromIndex);
            }
            // find the noun
            if (fully_separate[i][1].contains("N")) {
                vpToIndex = i;
                System.out.println("N-key: '" + fully_separate[i][0] + "' on index " + vpToIndex);
            }

        }

        return 1;
    }

}

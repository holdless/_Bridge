/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
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
    public static void main(String[] args) 
    {
        /////////
        /////// 
        // input voice: usually from RPi mic
        String rawSentence = "tango where is boston";
        System.out.println("original sentence: " + rawSentence);
        ///////
        ////////
        
        // make sure all chars to lower-case
        String lowerCaseSentence = rawSentence.toLowerCase();
        
        // check if the input voice is "to Robot" or not
        int fromIndex = 0;
        boolean __talkToRobot = false;
        String ROBOT_NAME = "tango";
        if (lowerCaseSentence.contains(ROBOT_NAME))
        {
            fromIndex = lowerCaseSentence.indexOf(ROBOT_NAME) + ROBOT_NAME.length() + 1;
//            System.out.println("index is: " + fromIndex);
            __talkToRobot = true;
        }
        
        //////////////////////////////////////////////////////////////////////////
        // if the the voice is "to Robot", then do the following NLP /////////////
        //////////////////////////////////////////////////////////////////////////
        if (__talkToRobot)
        {
            // path of stanford pos-tagger, parser
            String taggerModel = "D:/Users/changyht/Documents/NetBeansProjects/Stanford Pos Tagger/english-left3words-distsim.tagger";
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
            
/*            //// "pos-tagging"
            System.out.println("\n---- start pos-tagging -----");
            String taggedSent = tag(myTagger, extractedSent);
//            System.out.println(taggedSent);
            
            // acquire the separated word-tag array (nx2)
            String[] individual_word = taggedSent.split(" ");
            String[][] fully_separate = new String[individual_word.length][2];
            
            for (int i = 0; i < individual_word.length; i++) 
            {
                fully_separate[i] = individual_word[i].split("_");
                System.out.println(Arrays.toString(fully_separate[i]));   
            }
*/
            //// "parsing phrase"
            System.out.println("\n---- start parsing phrase -----");
            parsePhrase(lp, extractedSent);

/*            //// syntax analysis
            System.out.println("\n---- syntax analyzing -----");
            int a = syntaxAnalysis(fully_separate, individual_word.length);
*/
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // init stanford pos-tagger
    public static MaxentTagger initTagger(String path)
    {
        // Initialize the tagger
        MaxentTagger tagger = new MaxentTagger(path);
        return tagger;
    }
    // init stanford parser
    public static LexicalizedParser initParser(String path)
    {
        return LexicalizedParser.loadModel(path);
    }

    /**
     * demoAPI demonstrates other ways of calling the parser with
     * already tokenized text, or in some cases, raw text that needs to
     * be tokenized as a single sentence.  Output is handled with a
     * TreePrint object.  Note that the options used when creating the
     * TreePrint can determine what results to print out.  Once again,
     * one can capture the output by passing a PrintWriter to
     * TreePrint.printTree. This code is for English.
     * @param lp: lexicalized parser
     * @param sentence: extracted sentence
     */
    
    public static void parsePhrase(LexicalizedParser lp, String sentence) 
    {
        // This option shows parsing a list of correctly tokenized words
        String[] sent = sentence.split(" ");
//        String[] sent = { "This", "is", "an", "easy", "sentence", "." };
        List<CoreLabel> rawWords = Sentence.toCoreLabelList(sent);
        Tree parse = lp.apply(rawWords);
        parse.pennPrint();
        System.out.println();
        
        // SINV: did you, does he, could you...
        // SBARQ: who is, what
        ArrayList<Integer> depthCC = new ArrayList<>();
        ArrayList<Integer> depthVP = new ArrayList<>();
        ArrayList<Integer> depthSBAR = new ArrayList<>();
        ArrayList<Integer> depthSBARQ = new ArrayList<>();
        ArrayList<String> sCC = new ArrayList<>();
        ArrayList<String> sVP = new ArrayList<>();
        ArrayList<String> sSBAR = new ArrayList<>();
        ArrayList<String> sSBARQ = new ArrayList<>();

        ArrayList<String> commandSent = new ArrayList<>();
        ArrayList<Integer> commandDepth = new ArrayList<>();
        
      
        for (Tree A: parse)
        {
//            System.out.println(A.isLeaf());
//            System.out.println(A.isPhrasal());
            if(A.label().value().equals("CC"))
            {
                depthCC.add(parse.depth(A));
                String aa = A.yieldWords().toString();
                sCC.add(aa.substring(1, aa.length()-1).replace(",", ""));
            }
            if(A.label().value().equals("SBAR"))
            {
                depthSBAR.add(parse.depth(A));
                String aa = A.yieldWords().toString();
                sSBAR.add(aa.substring(1, aa.length()-1).replace(",", ""));
            }
            if(A.label().value().equals("SBARQ"))
            {
                depthSBARQ.add(parse.depth(A));
                String aa = A.yieldWords().toString();
                sSBARQ.add(aa.substring(1, aa.length()-1).replace(",", ""));
            }
            if(A.label().value().equals("VP"))
            {
                depthVP.add(parse.depth(A));
                String aa = A.yieldWords().toString();
                sVP.add(aa.substring(1, aa.length()-1).replace(",", ""));
            }
            
        }
        
        if (depthCC.isEmpty())
        {
            for (int j = 0; j < depthVP.size(); j++)
            {
                commandSent.add(sVP.get(j));
                commandDepth.add(depthVP.get(j));
            }
            for (int j = 0; j < depthSBAR.size(); j++) 
            {
                commandSent.add(sSBAR.get(j));
                commandDepth.add(depthSBAR.get(j));
            }
            for (int j = 0; j < depthSBARQ.size(); j++) 
            {
                commandSent.add(sSBARQ.get(j));
                commandDepth.add(depthSBARQ.get(j));
            }
        }
        else 
        {
            for (int i = 0; i < depthCC.size(); i++) 
            {
                if (i > 0 && depthCC.get(i).equals(depthCC.get(0))) {
                    break;
                }

                for (int j = 0; j < depthVP.size(); j++) {
                    if (depthVP.get(j).equals(depthCC.get(i))) {
                        commandSent.add(sVP.get(j));
                        commandDepth.add(depthVP.get(j));
                    }
                }
                for (int j = 0; j < depthSBAR.size(); j++) {
                    if (depthSBAR.get(j).equals(depthCC.get(i))) {
                        commandSent.add(sSBAR.get(j));
                        commandDepth.add(depthSBAR.get(j));
                    }
                }
                for (int j = 0; j < depthSBARQ.size(); j++) {
                    if (depthSBARQ.get(j).equals(depthCC.get(i))) {
                        commandSent.add(sSBARQ.get(j));
                        commandDepth.add(depthSBARQ.get(j));
                    }
                }
            }
        }
        
        // display commands
        for (int i = 0; i < commandSent.size(); i++)
        {
            System.out.print("depth:"+commandDepth.get(i));
            System.out.println(">>command: "+commandSent.get(i));
        }
        for (int i = 0; i < depthCC.size(); i++)
        {
            System.out.print("depth:"+depthCC.get(i));
            System.out.println(">>CC: "+sCC.get(i));
        }
        
    }
    
    public static void handleCommand(LexicalizedParser lp, MaxentTagger tagger, String command)
    {
        String[] sent = command.split(" ");
//        String[] sent = { "This", "is", "an", "easy", "sentence", "." };
        List<CoreLabel> rawWords = Sentence.toCoreLabelList(sent);
        Tree parse = lp.apply(rawWords);
        parse.pennPrint();
        System.out.println();

        String propPhrase = null;        
        String verbPhrase = null;        
        String nounPhrase = null;        
      
        for (Tree A: parse)
        {
//            System.out.println(A.isLeaf());
//            System.out.println(A.isPhrasal());
            if(A.label().value().equals("PP"))
            {
                String aa = A.yieldWords().toString();
                propPhrase = (aa.substring(1, aa.length()-1).replace(",", ""));
                System.out.println(propPhrase);
            }
            if(A.label().value().equals("VP"))
            {
                String aa = A.yieldWords().toString();
                verbPhrase = (aa.substring(1, aa.length()-1).replace(",", ""));
                System.out.println(verbPhrase);
            }
            if(A.label().value().equals("NP"))
            {
                String aa = A.yieldWords().toString();
                nounPhrase = (aa.substring(1, aa.length()-1).replace(",", ""));
                System.out.println(nounPhrase);
            }
        }        
    }


    // smash prefix
    public static String smashPrefix(String lowerCaseSentence)
    {
        int fromIndex = 0;
        int toIndex = lowerCaseSentence.length();
        //// unnecessary words elimination...
        // stage 1: "would you" rule
        if (lowerCaseSentence.contains("would you") ||
            lowerCaseSentence.contains("could you") ||
            lowerCaseSentence.contains("can you")
                )
        {
            fromIndex = lowerCaseSentence.indexOf("you") + "you".length() + 1;
            // "please" rule: "please/mind" follow "would you"
            if (lowerCaseSentence.substring(fromIndex, fromIndex + "please".length()).equals("please"))
                fromIndex = fromIndex + "please".length() + 1;
            else if (lowerCaseSentence.substring(fromIndex, fromIndex + "mind".length()).equals("mind"))
                fromIndex = fromIndex + "mind".length() + 1;
            
            // "tell me/help me" rule
            if (lowerCaseSentence.substring(fromIndex, fromIndex + "tell me".length()).equals("tell me"))
                fromIndex = fromIndex + "tell me".length() + 1;
            else if (lowerCaseSentence.substring(fromIndex, fromIndex + "help me".length()).equals("help me"))
                fromIndex = fromIndex + "help me".length() + 1;
            
//            System.out.println("index is: " + fromIndex);
        }
        // stage 1: "how about" rule
        else if (lowerCaseSentence.contains("how about"))
        {
            fromIndex = "how about".length() + 1;
//            System.out.println("index is: " + fromIndex);
        }
        // stage 1: "would you mind" rule
        else if (lowerCaseSentence.contains("would you mind"))
        {
            fromIndex = "would you mind".length() + 1;
//            System.out.println("index is: " + fromIndex);
        }
        // stage 1: "let's" rule
        else if (lowerCaseSentence.contains("let's"))
        {
            fromIndex = "let's".length() + 1;
//            System.out.println("index is: " + fromIndex);
        }
        // stage 1: "...think about" rule
        else if (lowerCaseSentence.contains("think about"))
        {
            fromIndex = lowerCaseSentence.indexOf("think about") + "think about".length() + 1;
//            System.out.println("index is: " + fromIndex);
        }
        // stage 1: "do you know" rule
        else if (lowerCaseSentence.contains("do you know"))
        {
            fromIndex = "do you know".length() + 1;
//            System.out.println("index is: " + fromIndex);
        }
        
        // stage 2: "Start/end pleae" rule
        if (lowerCaseSentence.contains("please"))
        {
            if (lowerCaseSentence.indexOf("please") == 0)
                fromIndex = "please".length() + 1;
            if (lowerCaseSentence.indexOf("please") + "please".length() == lowerCaseSentence.length())
                toIndex = toIndex - "please".length();
            
//            System.out.println("index is: " + fromIndex);
        }
        
        String extractedSentence = lowerCaseSentence.substring(fromIndex, toIndex);
        return extractedSentence;
    }
    
    // tag extracted sentence
    public static String tag(MaxentTagger tagger, String extractedSentence)
    {
        // stage 3: pos-tagging
        // The tagged string
        String tagged_str = tagger.tagString(extractedSentence);

            
        return tagged_str;
    }
    
    // after tags acquired, do syntax analysis: understand meaning and execute order
    public static int syntaxAnalysis (String[][] fully_separate, int sentenceLength)
    {
        int vpFromIndex = 0;
        int vpToIndex = sentenceLength;
        // start syntax analysis: sorting by key.
        for (int i = 0; i < sentenceLength; i++) 
        {
            if (fully_separate[i][1].contains("W"))
                System.out.println("WH-key: '" + fully_separate[i][0] + "' on index " + i);  
            
            // find the verb-phrase
            // find the verb
            if (fully_separate[i][1].contains("V"))
            {
                vpFromIndex = i;
                System.out.println("V-key: '" + fully_separate[i][0] + "' on index " + vpFromIndex);
            }
            // find the noun
            if (fully_separate[i][1].contains("N"))
            {
                vpToIndex = i;
                System.out.println("N-key: '" + fully_separate[i][0] + "' on index " + vpToIndex);
            }
            
            

        }
        
        
        
        return 1;
    }
    
}

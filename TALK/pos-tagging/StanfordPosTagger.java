/*
603.5.0115
to create this java project:
0) can use newest stanford pos-tagger model
1) on "Library" folder right click > Add JAR/Folder > add "stanford-postagger.jar"
2) on "Library" folder right click > Add JAR/Folder > add "slf4j-api.jar", "slf4j-simple.jar"

605.3.0127
extract "fully separate" information from tagged_str

606.4.0204
start sorting: imperative sentence
*/

package stanford.pos.tagger;

/**
 *
 * @author changyht
 */
//import java.io.IOException;
import edu.stanford.nlp.tagger.maxent.MaxentTagger;
import java.util.Arrays;

public class StanfordPosTagger {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) 
    {
        // input voice: usually from RPi mic
        String rawSentence = "tango could you please turn it on for amy";
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
        
        // if the the voice is "to Robot", then do tagging and following NLP
        if (__talkToRobot)
        {
            // path of stanford pos-tagger
            String taggerPath = "D:/Users/changyht/Documents/NetBeansProjects/Stanford Pos Tagger/english-left3words-distsim.tagger";
            String sentence = lowerCaseSentence.substring(fromIndex);
            MaxentTagger myTagger = init(taggerPath);
            String tagged_str = tag(myTagger, sentence);
            
            // output the tagged sentence
            System.out.println(tagged_str);

            // acuire the separated word-tag array (nx2)
            String[] individual_word = tagged_str.split(" ");
            String[][] fully_separate = new String[individual_word.length][2];
            
            for (int i = 0; i < individual_word.length; i++) 
            {
                fully_separate[i] = individual_word[i].split("_");
                System.out.println(Arrays.toString(fully_separate[i]));   
            }
            
            int a = syntaxAnalysis(fully_separate, individual_word.length);

        }
    }
    //////////////////////////////////////////////////////////////////////////////
    // init stanford pos-tagger
    public static MaxentTagger init(String path)
    {
        // Initialize the tagger
        MaxentTagger tagger = new MaxentTagger(path);
        return tagger;
    }

    // tag extracted sentence
    public static String tag(MaxentTagger tagger, String lowerCaseSentence)
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

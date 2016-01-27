/*
603.5.0115
to create this java project:
0) can use newest stanford pos-tagger model
1) on "Library" folder right click > Add JAR/Folder > add "stanford-postagger.jar"
2) on "Library" folder right click > Add JAR/Folder > add "slf4j-api.jar", "slf4j-simple.jar"

605.3.0127
extract "fully separate" information from tagged_str
*/

package stanford.pos.tagger;

/**
 *
 * @author changyht
 */
import java.io.IOException;
import edu.stanford.nlp.tagger.maxent.MaxentTagger;
import java.util.Arrays;

public class StanfordPosTagger 
{
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) 
    {
        // TODO code application logic here
        String sentence = "what you believe is all junk";
        String path = "D:/Users/changyht/Documents/NetBeansProjects/Stanford Pos Tagger/english-left3words-distsim.tagger";
        MaxentTagger tagger = init(path);
        int a = tag(tagger, sentence);
        System.out.println(a);
    }
    
    public static MaxentTagger init(String path)
    {
        // Initialize the tagger
        MaxentTagger tagger = new MaxentTagger(path);
        return tagger;
    }
    
    public static int tag(MaxentTagger tagger, String sentence)
    {
        // The tagged string
        String tagged_str = tagger.tagString(sentence);
        String[] individual_word = tagged_str.split(" ");
        String[][] fully_separate = new String[individual_word.length][2];
        // Output the result
        System.out.println(tagged_str);   
        
        for (int i = 0; i < individual_word.length; i++) 
        {
            fully_separate[i] = individual_word[i].split("_");
            System.out.println(Arrays.toString(fully_separate[i]));   

            if (fully_separate[i][1].equals("WP"))
                System.out.println("key word:" + fully_separate[i][0]);   
                
        }
            
        return 1;
    }
}

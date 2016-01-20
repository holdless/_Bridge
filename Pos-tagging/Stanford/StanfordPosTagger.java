/*
603.5.0115
to create this java project:
0) can use newest stanford pos-tagger model
1) on "Library" folder right click > Add JAR/Folder > add "stanford-postagger.jar"
2) on "Library" folder right click > Add JAR/Folder > add "slf4j-api.jar", "slf4j-simple.jar"
*/
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package stanford.pos.tagger;

import java.io.IOException;
import edu.stanford.nlp.tagger.maxent.MaxentTagger;

public class StanfordPosTagger 
{
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) 
    {
        // TODO code application logic here
        String sentence = "call from java main";
        String path = ".../Documents/NetBeansProjects/Stanford Pos Tagger/english-left3words-distsim.tagger";
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
        String tagged = tagger.tagString(sentence);
 
        // Output the result
        System.out.println(tagged);   
        
        return 1;
    }
}

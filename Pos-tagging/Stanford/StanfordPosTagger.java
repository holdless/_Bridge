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

/**
 *
 * @author changyht
 */
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
        MaxentTagger a = tag();
        System.out.println(a);
    }
    
    public static MaxentTagger tag()
    {
        // Initialize the tagger
        MaxentTagger tagger = new MaxentTagger(".../NetBeansProjects/Stanford Pos Tagger/english-left3words-distsim.tagger");
//        MaxentTagger tagger = new MaxentTagger(_path);
 
        // The sample string
        String sample = "hello, my name is jack, how are you doing today?";
 
        // The tagged string
        String tagged = tagger.tagString(sample);
 
        // Output the result
        System.out.println(tagged);   
        
        return tagger;
    }
}


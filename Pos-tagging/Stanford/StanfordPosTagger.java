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
        tag();
    }
    
    static void tag()
    {
        // Initialize the tagger
        MaxentTagger tagger = new MaxentTagger("english-left3words-distsim.tagger");
 
        // The sample string
        String sample = "hello, my name is jack, how are you doing today?";
 
        // The tagged string
        String tagged = tagger.tagString(sample);
 
        // Output the result
        System.out.println(tagged);    
    }
}

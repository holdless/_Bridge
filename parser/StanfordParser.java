/*
 add jar files:
1. stanford-parser.jar
2. slf4j-api.jar
3. slf4j-simple.jar
4. stanford-parser-3.6.0-models.jar
 */
package stanfordparser;

//import java.util.Collection;
import java.util.List;
import java.io.StringReader;

import edu.stanford.nlp.process.Tokenizer;
import edu.stanford.nlp.process.TokenizerFactory;
import edu.stanford.nlp.process.CoreLabelTokenFactory;
//import edu.stanford.nlp.process.DocumentPreprocessor;
import edu.stanford.nlp.process.PTBTokenizer;
import edu.stanford.nlp.ling.CoreLabel;
//import edu.stanford.nlp.ling.HasWord;
import edu.stanford.nlp.ling.Sentence;
import edu.stanford.nlp.trees.*;
import edu.stanford.nlp.parser.lexparser.LexicalizedParser;

public class StanfordParser {
    
    public static void main(String[] args) 
    {
        String parserModel = "edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz";
        LexicalizedParser lp = LexicalizedParser.loadModel(parserModel);
        
        parsePhrase(lp);
    }
    
    public static LexicalizedParser init(String parserModel)
    {
        return LexicalizedParser.loadModel(parserModel);
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
   */
    
    public static void parsePhrase(LexicalizedParser lp) 
    {
        // This option shows parsing a list of correctly tokenized words
        String sent0 = "pick up the phone or get out";
        String[] sent = sent0.split(" ");
//        String[] sent = { "This", "is", "an", "easy", "sentence", "." };
        List<CoreLabel> rawWords = Sentence.toCoreLabelList(sent);
        Tree parse = lp.apply(rawWords);
        parse.pennPrint();
        System.out.println();
        
        // SINV: did you, does he, could you...
        // SBARQ: who is, what
        for (Tree A: parse)
        {
//            System.out.println(A.isLeaf());
//            System.out.println(A.isPhrasal());
            if(A.label().value().equals("VP"))
            {
//\                int nodeNum = A.nodeNumber(parse);
//                System.out.println(nodeNum);
//                System.out.println(parse.depth());
//                System.out.println(A.depth());
                
                System.out.println(parse.depth(A));
                String aa = A.yieldWords().toString();
                System.out.println(aa.substring(1, aa.length()-1).replace(",", ""));
//                System.out.println(A.getChild(0));
            }
        }
/*        
        // This option shows loading and using an explicit tokenizer
        String sent2 = "turn on the light";
        TokenizerFactory<CoreLabel> tokenizerFactory =
            PTBTokenizer.factory(new CoreLabelTokenFactory(), "");
        Tokenizer<CoreLabel> tok =
            tokenizerFactory.getTokenizer(new StringReader(sent2));
        List<CoreLabel> rawWords2 = tok.tokenize();
        parse = lp.apply(rawWords2);

        TreebankLanguagePack tlp = lp.treebankLanguagePack(); // PennTreebankLanguagePack for English
        GrammaticalStructureFactory gsf = tlp.grammaticalStructureFactory();
        GrammaticalStructure gs = gsf.newGrammaticalStructure(parse);
        List<TypedDependency> tdl = gs.typedDependenciesCCprocessed();
        System.out.println(tdl);
        System.out.println();

        // You can also use a TreePrint object to print trees and dependencies
        TreePrint tp = new TreePrint("penn,typedDependenciesCollapsed");
        tp.printTree(parse);
*/
  }
    
}

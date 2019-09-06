import java.io.BufferedReader;
import java.io.Console;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Paths;
 
import java.util.Scanner;

import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
 
public class LuceneReadIndexFromFileExample
{
    //directory contains the lucene indexes
    private static final String INDEX_DIR = "indexedFiles";
 
    public static void main(String[] args) throws Exception
    {
        //Create lucene searcher. It search over a single IndexReader.
        IndexSearcher searcher = createSearcher();
         
        //Search indexed contents using search term
        System.out.print("Query: ");
        Scanner scan=new Scanner(System.in);
        
        String old_query = scan.nextLine();
        String query = generatelmvec(old_query);

        TopDocs foundDocs = searchInContent(query, searcher);
         
        //Total found documents
        System.out.println("Total Results :: " + foundDocs.totalHits);
         
        //Let's print out the path of files which have searched term
        for (ScoreDoc sd : foundDocs.scoreDocs)
        {
            Document d = searcher.doc(sd.doc);
            System.out.println("Path : "+ d.get("path") + ", Score : " + sd.score);
        }
    }
     
    private static TopDocs searchInContent(String textToFind, IndexSearcher searcher) throws Exception
    {
        //Create search query
        QueryParser qp = new QueryParser("contents", new StandardAnalyzer());
        Query query = qp.parse(textToFind);
         
        //search the index
        TopDocs hits = searcher.search(query, 10);
        return hits;
    }
 
    private static IndexSearcher createSearcher() throws IOException
    {
        Directory dir = FSDirectory.open(Paths.get(INDEX_DIR));
         
        //It is an interface for accessing a point-in-time view of a lucene index
        IndexReader reader = DirectoryReader.open(dir);
         
        //Index searcher
        IndexSearcher searcher = new IndexSearcher(reader);
        return searcher;
    }

    public static String generatelmvec(String word) 
    {
	    String s = null;
	    String synonyms = "";
	
	    try {
		
		    // run the Unix "ps -ef" command
		        // using the Runtime exec method:
		        String str = word;
		        String command =  "python3 lemmatiser_wrapper.py"+" "+str;
		        Process p = Runtime.getRuntime().exec(command);
		        BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
		
		        BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));
		
		        // read the output from the command
		        //System.out.println("Here is the standard output of the command:\n");
		        while ((s = stdInput.readLine()) != null) {
		            synonyms += " "+s;
		        }
		
		        // read any errors from the attempted command
		        //System.out.println("Here is the standard error of the command (if any):\n");
		        while ((s = stdError.readLine()) != null) {
		            System.out.println(s);
		        }
		
		        //System.exit(0);
	    }
	    catch (IOException e) {
	        System.out.println("exception happened - here's what I know: ");
	        e.printStackTrace();
	        System.exit(-1);
	    }
	    //System.out.println(synonyms);
	    return synonyms;
    }

}

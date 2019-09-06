import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
 
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.Field.Store;
import org.apache.lucene.document.LongPoint;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.index.IndexWriterConfig.OpenMode;
import org.apache.lucene.index.Term;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
 
public class LuceneWriteIndexFromFileExample
{
    public static void main(String[] args)
    {
        //Input folder
        String docsPath = "inputFiles";
         
        //Output folder
        String indexPath = "indexedFiles";
 
        //Input Path Variable
        final Path docDir = Paths.get(docsPath);
 
        try
        {
            Directory dir = FSDirectory.open( Paths.get(indexPath) );
            Analyzer analyzer = new StandardAnalyzer();
            IndexWriterConfig iwc = new IndexWriterConfig(analyzer);
            iwc.setOpenMode(OpenMode.CREATE_OR_APPEND);
             
            IndexWriter writer = new IndexWriter(dir, iwc);
             
            indexDocs(writer, docDir);
 
            writer.close();
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }
     
    static void indexDocs(final IndexWriter writer, Path path) throws IOException
    {
        if (Files.isDirectory(path))
        {
            Files.walkFileTree(path, new SimpleFileVisitor<Path>()
            {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException
                {
                    try
                    {
                        indexDoc(writer, file, attrs.lastModifiedTime().toMillis());
                    }
                    catch (IOException ioe)
                    {
                        ioe.printStackTrace();
                    }
                    return FileVisitResult.CONTINUE;
                }
            });
        }
        else
        {
            indexDoc(writer, path, Files.getLastModifiedTime(path).toMillis());
        }
    }
 
    static void indexDoc(IndexWriter writer, Path file, long lastModified) throws IOException
    {
        try (InputStream stream = Files.newInputStream(file))
        {
            Document doc = new Document();
             
            doc.add(new StringField("path", file.toString(), Field.Store.YES));
            doc.add(new LongPoint("modified", lastModified));
            String line = new String(Files.readAllBytes(file));
            String new_str = generatelmvec(line);
            doc.add(new TextField("contents", new_str, Store.YES));
             
            writer.updateDocument(new Term("path", file.toString()), doc);
        }
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

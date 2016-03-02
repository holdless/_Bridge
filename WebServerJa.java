/*
609.4.0225@hsinchu
610.2.0301@hsinchu
  <HTTP transmission mechanism:>
    [Client request]: "GET /a.html HTTP/1.1" or "GET / HTTP/1.1"
    [SRV response]:   "HTTP/1.1 200 OK\r\n"
                      "Content-Type: text/html\r\n"
          case 1 - 直接傳回 html/jpeg/...etc 檔案:
                      "Content-Length: <# of bytes>\r\n"
                      "...<contents>"
          case 2 - 直接寫入 html 格式指令, 或在傳回檔案外額外加寫指令
    [Client execute & request]:
          若 html 內有 media (image or video ...etc)等需求, 會再送出 request. ex:
                      "GET /images/moniz.jpg HTTP/1.1"
    [SRV response]:   continuing...

<favicon.ico issue:>
  1. Browser 第一次連線時, 會去 "root" 下面找有沒有 "favicon.ico". ex: "http://localhost/favicon.ico"
  2. custom type: 需在頁面中指定: <link rel="SHORTCUT ICON" href="<icon name.ico>">
  3. 同樣的名字"只會找一次", 以後就不會找了. 所以若想換 icon, 最好換掉 icon 的名字.

<my folder conventions:>
  1. image files: images/
  2. icon files: icons/
  3. html files: root directory
  
<path default:>
  Java project "root" directory
 */
package wjawebserver;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
//import java.net.ServerSocket;
//import java.net.Socket;
import java.util.StringTokenizer;


/**
 *
 * @author changyht
 */
public class WJaWebServer {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException
    {
        webServer2(8088);
    }
/*    
    public static void webServer(int localPort) throws IOException
    {
        ServerSocket listener = new ServerSocket(localPort);
        while(true)
        {
            Socket sock = listener.accept();
            new PrintWriter(sock.getOutputStream(), true).println("Goodbye, World!");
            sock.close();
        }
    }
*/    
    public static void webServer2(int localPort) throws IOException
    {
        String requestMessageLine;
        String fileName;
        System.out.println("Web Server Starting on Port " + localPort);
        ServerSocket s = new ServerSocket(localPort);


        System.out.println("Waiting for Connecting...");
        
        while(true) 
        {
            Socket serverSocket = s.accept();
            System.out.println("Connection, sending data.");
            BufferedReader in = new BufferedReader(new InputStreamReader(serverSocket.getInputStream()));
            DataOutputStream outToClient = new DataOutputStream(serverSocket.getOutputStream());

            requestMessageLine = in.readLine();
            
            if (requestMessageLine != null) // 609.4.0225 hiroshi:after first loop wont post any string
            {
                StringTokenizer tokenizedLine = new StringTokenizer(requestMessageLine);

                if (tokenizedLine.nextToken().equals("GET")) 
                {
                    fileName = tokenizedLine.nextToken();
                    if(fileName.startsWith("/")==true)
                        fileName = fileName.substring(1);

                    if(!fileName.isEmpty()) 
                    {
                        String filePath = "";
                        String formatTag = "text/html";
                        boolean correctFileName = true;
                        
                        if (fileName.endsWith(".html"))
                        {
                            filePath = "";
                            formatTag = "text/html";
                        }
                        else if (fileName.endsWith(".ico"))
                        {
                            filePath = "icons/";
                            formatTag = "icon/ico";
                        }
                        else if (fileName.endsWith(".jpg"))
                        {
                            filePath = "images/";
                            formatTag = "image/jpeg";
                        }
                        else if (fileName.endsWith(".gif"))
                        {
                            filePath = "images/";
                            formatTag = "image/gif";
                        }
                        else if (fileName.endsWith(".png"))
                        {
                            filePath = "images/";
                            formatTag = "image/png";
                        }
                        else
                            correctFileName = false;
                        
                        if (correctFileName)
                        {
                        File file = new File(filePath + fileName);
                        int numOfBytes = (int) file.length();

                        FileInputStream inFile = new FileInputStream(filePath + fileName);
   
                        byte[] fileInBytes = new byte[numOfBytes];

                        inFile.read(fileInBytes);

                        outToClient.writeBytes("HTTP/1.1 200 OK\r\n");
                        outToClient.writeBytes("Content-Type: " + formatTag + "\r\n");
//                        outToClient.writeBytes("Content-Type: image/jpeg\r\n");
                        outToClient.writeBytes("Content-Length: "+numOfBytes+"\r\n");
                        outToClient.writeBytes("\r\n");
                        outToClient.write(fileInBytes, 0, numOfBytes);
                        inFile.close();
                        System.out.println("Sending data completely.");
                        }
                    }
                    else 
                    {
                        outToClient.writeBytes("HTTP/1.1 200 OK\r\n");
                        outToClient.writeBytes("Content-Type: text/html\r\n");
                        outToClient.writeBytes("\r\n");
                        outToClient.writeBytes("<head>");
                        outToClient.writeBytes("<LINK REL='SHORTCUT ICON' HREF='blueJ.ico'>\r\n");
                        outToClient.writeBytes("<title>TITLE</title>\r\n");
                        outToClient.writeBytes("</head>");
                        outToClient.writeBytes("<body>");
                        outToClient.writeBytes("<h1>Welcome to the Java WebServer</h1>\r\n");
                        outToClient.writeBytes("<p>welcome to the jungle</p>\r\n");
                        outToClient.writeBytes("<a href = \"http://www.google.com\">google</a>\r\n");
                        outToClient.writeBytes("<img src = 'cdsem.jpg' alt='yes' width='600' height='400'>\r\n");
                        outToClient.writeBytes("</body>");
                        System.out.println("Sending data completely.");
                    }
                    serverSocket.close();
                    outToClient.flush();
                }
                else
                    System.out.println("Bad Request Message");
            
            }
        }
    }
}

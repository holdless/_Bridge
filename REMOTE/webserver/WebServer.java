/*
609.4.0225----------@hsinchu
610.2.0301----------@hsinchu
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
  
610.3.0302----------@hsinchu
<log> add exception handle
<log> add form/button/submit msg handle (notice that msg will always end with "?")

610.5.0304----------@hsinchu
<log> server-sent events
 */
package wjawebserver;

import java.io.*; // for exception handle
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
    public static void main(String[] args) throws IOException {
        webServer2(8088);
    }

    public static void exceptionMsg(DataOutputStream outToClient,
            String sysMsg,
            String htmlTitle,
            String htmlH1) throws IOException {
        System.out.println(sysMsg);
        outToClient.writeBytes("HTTP/1.1 200 OK\r\n");
        outToClient.writeBytes("Content-Type: text/html\r\n");
        outToClient.writeBytes("\r\n");
        outToClient.writeBytes("<head>");
        outToClient.writeBytes("<LINK REL='SHORTCUT ICON' HREF='blueJ.ico'>\r\n");
        outToClient.writeBytes("<title>" + htmlTitle + "</title>\r\n");
        outToClient.writeBytes("</head>");
        outToClient.writeBytes("<body>");
        outToClient.writeBytes("<h1>" + htmlH1 + "</h1>");
        outToClient.writeBytes("</body>");

    }

    public static void simpleHTMLResponse(DataOutputStream outToClient,
            String htmlH1) throws IOException {
        System.out.println(">>simple HTML reponse>>");
        outToClient.writeBytes("HTTP/1.1 200 OK\r\n");
        outToClient.writeBytes("Content-Type: text/html\r\n");
        outToClient.writeBytes("\r\n");
        outToClient.writeBytes("<head>");
        outToClient.writeBytes("<LINK REL='SHORTCUT ICON' HREF='blueJ.ico'>\r\n");
        outToClient.writeBytes("<title>simple HTML response</title>\r\n");
        outToClient.writeBytes("</head>");
        outToClient.writeBytes("<body>");
        outToClient.writeBytes("<h1>" + htmlH1 + "</h1>");
        outToClient.writeBytes("</body>");
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
    public static void webServer2(int localPort) throws IOException {
        String requestMessageLine;
        String fileName;
        System.out.println("Web Server Starting on Port " + localPort);
        ServerSocket s = new ServerSocket(localPort);

        System.out.println("Waiting for Connecting...");

        int showUp = 0;
        while (true) {
            Socket serverSocket = s.accept();
            System.out.println("Connection, sending data.");
            BufferedReader in = new BufferedReader(new InputStreamReader(serverSocket.getInputStream()));
            DataOutputStream outToClient = new DataOutputStream(serverSocket.getOutputStream());

            requestMessageLine = in.readLine();

            if (requestMessageLine != null) // 609.4.0225 hiroshi:after first loop wont post any string
            {
                StringTokenizer tokenizedLine = new StringTokenizer(requestMessageLine);

                if (tokenizedLine.nextToken().equals("GET")) {
                    fileName = tokenizedLine.nextToken();
                    if (fileName.startsWith("/") == true) {
                        fileName = fileName.substring(1);
                    }

                    if (!fileName.isEmpty()) {
                        String filePath = "";
                        String formatTag = "text/html";
                        boolean isCmd = false;
                        boolean isSrvSent = false;

                        if (fileName.endsWith(".html")) {
                            filePath = "";
                            formatTag = "text/html";
                        } else if (fileName.endsWith(".ico")) {
                            filePath = "icons/";
                            formatTag = "icon/ico";
                        } else if (fileName.endsWith(".jpg")) {
                            filePath = "images/";
                            formatTag = "image/jpeg";
                        } else if (fileName.endsWith(".gif")) {
                            filePath = "images/";
                            formatTag = "image/gif";
                        } else if (fileName.endsWith(".png")) {
                            filePath = "images/";
                            formatTag = "image/png";
                        } // remote control instruction
                        else if (fileName.startsWith("myCmd")) {
                            isCmd = true;
                            filePath = "";
                            formatTag = "text/html";
                        } // server-sent events
                        else if (fileName.startsWith("srvSent")) {
                            isSrvSent = true;
                        }

                        if (isCmd) {
                            if (fileName.endsWith("up?")) {
//                                simpleHTMLResponse(outToClient, "UP");
                                showUp = 1;
                            } else if (fileName.endsWith("down?")) {
                                //simpleHTMLResponse(outToClient, "DOWN");
                                showUp = 0;
                            } else if (fileName.endsWith("right?")) {
                                //simpleHTMLResponse(outToClient, "RIGHT");
                                showUp = 0;
                            } else if (fileName.endsWith("left?")) {
                                //simpleHTMLResponse(outToClient, "LEFT");
                                showUp = 0;
                            } else {
                                showUp = 0;
                                exceptionMsg(outToClient,
                                        "Exception::Command not found.",
                                        "Command Not Found!!",
                                        "no such command!");
                            }
                        }

                        if (isCmd)
                        {
                            outToClient.writeBytes("HTTP/1.1 204 No Content\r\n");
                        }
                        else if (isSrvSent) 
                        {
                            System.out.println("server-sent...");

                            outToClient.writeBytes("HTTP/1.1 200 OK\r\n");
                            outToClient.writeBytes("Content-Type: text/event-stream\n\n");
//                            outToClient.writeBytes("Content-Type: text/event-stream; charset=utf-8\n\n");
                            outToClient.writeBytes("Cache-Control: no-cache\r\n");
                            outToClient.writeBytes("\r\n");
                            outToClient.writeBytes("event: message\n");
                            outToClient.writeBytes("data: " + System.currentTimeMillis() + "\n\n");
                            outToClient.writeBytes("event:cmdUp\n");
                            outToClient.writeBytes("data: " + showUp + "\n\n");

                        } 
                        else 
                        {
                            try 
                            {
                                File file = new File(filePath + fileName);
                                int numOfBytes = (int) file.length();
                                FileInputStream inFile = new FileInputStream(filePath + fileName);
                                byte[] fileInBytes = new byte[numOfBytes];

                                inFile.read(fileInBytes);

                                outToClient.writeBytes("HTTP/1.1 200 OK\r\n");
                                outToClient.writeBytes("Content-Type: " + formatTag + "\r\n");
                                outToClient.writeBytes("Content-Length: " + numOfBytes + "\r\n");
                                outToClient.writeBytes("\r\n");
                                outToClient.write(fileInBytes, 0, numOfBytes);
                                inFile.close();

                                System.out.println("Sending data completely.");
                            } 
                            catch (FileNotFoundException fnf) 
                            {
                                outToClient.writeBytes("\r\n");
                                exceptionMsg(outToClient,
                                        "Exception:: file not found!",
                                        "File Not Found!!",
                                        "file not found/no such operation!");
                            }
                        }
                    } 
                    else // "GET / HTTP/1.1"
                    {
                        outToClient.writeBytes("HTTP/1.1 200 OK\r\n");
                        outToClient.writeBytes("Content-Type: text/html\r\n");
                        outToClient.writeBytes("\r\n");
                        outToClient.writeBytes("<head>");
                        outToClient.writeBytes("<LINK REL='SHORTCUT ICON' HREF='blueJ.ico'>\r\n");
                        outToClient.writeBytes("<title>hiroshi's SRV</title>\r\n");
                        outToClient.writeBytes("</head>");
                        outToClient.writeBytes("<body>");
                        outToClient.writeBytes("<h1>Welcome to Data Server</h1>\r\n");
                        outToClient.writeBytes("<p>SEM-data:</p>\r\n");
                        outToClient.writeBytes("<a href = \"http://www.google.com\">google</a>\r\n");
                        outToClient.writeBytes("<img src = 'cdsem.jpg' alt='yes' width='600' height='400'>\r\n");
                        outToClient.writeBytes("</body>");
                        System.out.println("Sending data completely.");
                    }
                    serverSocket.close();
                    outToClient.flush();
                } 
                else 
                {
                    System.out.println("Bad Request Message");
                }

            }
        }
    }
}

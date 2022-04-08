package pl.psnc.dl.ege.webapp.servlet;

import org.json.JSONException;
import org.json.JSONObject;
import pl.psnc.dl.ege.webapp.request.InfoRequestResolver;
import pl.psnc.dl.ege.webapp.request.Method;
import pl.psnc.dl.ege.webapp.request.RequestResolver;
import pl.psnc.dl.ege.webapp.request.RequestResolvingException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.Properties;


@WebServlet(name = "InfoServlet", urlPatterns = {"/Info"})
public class InfoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        String serverInfo = getServletContext().getServerInfo();
        try {
            //create info json object
            JSONObject json_info = new JSONObject();
            json_info.put("version", getVersion(request));
            json_info.put("serverinfo", serverInfo);
            //resolve request and catch any errors
            RequestResolver rr = new InfoRequestResolver(request,
                    Method.GET);
            //print available validation options
            printInfo(response, rr, json_info);
        }
        catch (RequestResolvingException ex) {
            if (ex.getStatus().equals(
                    RequestResolvingException.Status.WRONG_METHOD)) {
                //TODO : something with "wrong" method message (and others)
                response.sendError(405, ConversionServlet.R_WRONG_METHOD);
            }
            else {
                throw new ServletException(ex);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    public synchronized String getVersion(HttpServletRequest request) {
        String version = null;

        // try to load from maven properties first
        try {
            Properties p = new Properties();
            InputStream is = request.getServletContext().getResourceAsStream("/META-INF/maven/pl.psnc.dl.ege.webapp/meigarage/pom.properties");
            if (is != null) {
                p.load(is);
                version = p.getProperty("version", "");
            }
        } catch (Exception e) {
            // ignore
        }

        // fallback to using Java API
        if (version == null) {
            Package aPackage = getClass().getPackage();
            if (aPackage != null) {
                version = aPackage.getImplementationVersion();
                if (version == null) {
                    version = aPackage.getSpecificationVersion();
                }
            }
        }

        if (version == null) {
            // we could not compute the version so use a blank
            version = "";
        }

        return version;
    }

    /*
     * Print info response
     */
    private void printInfo(HttpServletResponse response,
                                           RequestResolver rr, JSONObject json_info)
            throws ServletException
    {
        try {
            PrintWriter out = response.getWriter();
            if(json_info.length() == 0){
                response.setStatus(HttpServletResponse.SC_NO_CONTENT);
                return;
            }
            response.setContentType("application/json");
            out.println(json_info);
        }
        catch (IOException ex) {
            throw new ServletException(ex);
        }
    }
}

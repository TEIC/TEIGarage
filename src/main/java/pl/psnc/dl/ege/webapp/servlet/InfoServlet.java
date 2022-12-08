package pl.psnc.dl.ege.webapp.servlet;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import pl.psnc.dl.ege.webapp.servlethelpers.Info;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import java.io.IOException;



@WebServlet(name = "InfoServlet", urlPatterns = {"/Info"})
@OpenAPIDefinition(tags = {
        @Tag(name = "ege-webservice", description = "Conversion, Validation and Customization")
})
public class InfoServlet extends HttpServlet {
    Info info = new Info();
    @Override
    @GET
    @Path("ege-webservice/Info")
    @Operation(summary = "Get info on webservice", tags = "ege-webservice", description = "Return list of info on webservice", responses = {
            @ApiResponse(
                    description = "List of info is returned",
                    responseCode = "200",
                    content = @Content(mediaType = "application/json")),
            @ApiResponse(
                    description = "Wrong method error message if the method is called wrong",
                    responseCode = "405")
    })
    public void doGet(@Parameter(hidden = true) HttpServletRequest request, @Parameter(hidden = true) HttpServletResponse response)
            throws IOException, ServletException {
        info.doGetHelper(request, response, this);
        }

}

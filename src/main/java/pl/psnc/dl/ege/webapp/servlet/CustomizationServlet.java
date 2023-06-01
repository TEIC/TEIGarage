package pl.psnc.dl.ege.webapp.servlet;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.json.XML;
import pl.psnc.dl.ege.webapp.servlethelpers.Customization;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import java.io.IOException;


@OpenAPIDefinition(tags = {
        @Tag(name = "ege-webservice", description = "Conversion, Validation and Customization")
})
public class CustomizationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    Customization customization = new Customization();
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CustomizationServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    @Override
    @GET
	@Path("ege-webservice/Customization")
    @Operation(summary = "Get all available customizations", tags = "ege-webservice", description = "Return list of input data types and lists of possible customization paths", responses = {
            @ApiResponse(
                    description = "List of possible customizations is returned",
                    responseCode = "200",
                    content = @Content(mediaType = "text/xml")),
            @ApiResponse(
                    description = "Wrong method error message if the method is called wrong",
                    responseCode = "405")
    })
    public void doGet(
            @Parameter(hidden = true) HttpServletRequest request,
            @Parameter(hidden = true) HttpServletResponse response) throws ServletException, IOException {
        customization.doGetHelper(request, response);

    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    @Override
    @POST
	@Path("ege-webservice/Customization/{customization-setting}/{source}/{customization}")
    @Operation(summary = "Do customizations", tags = "ege-webservice", description = "Customize files into different data formats",
            parameters = {
                    @Parameter(
                            in = ParameterIn.PATH,
                            description = "Customization Setting",
                            required = true,
                            name = "customization-setting",
                            schema = @Schema(type= "string", format="text/plain")),
					@Parameter(
							in = ParameterIn.PATH,
							description = "Source",
							required = true,
							name = "source",
							schema = @Schema(type= "string", format="text/plain")),
					@Parameter(
							in = ParameterIn.PATH,
							description = "Customization",
							required = true,
							name = "customization",
							schema = @Schema(type= "string", format="text/plain"))
            },
            responses = {
                    @ApiResponse(
                            description = "The content of the customized file",
                            responseCode = "200",
							content = @Content(mediaType = "text/xml", schema = @Schema(implementation = XML.class))),
                    @ApiResponse(
                            description = "Wrong method error message if the method is called wrong",
                            responseCode = "405")
            })
    public void doPost(
            @Parameter(hidden = true) HttpServletRequest request,
            @Parameter(hidden = true) HttpServletResponse response) throws ServletException, IOException {
        customization.doPostHelper(request, response);
        }

}

package pl.psnc.dl.ege.webapp.servlet;

import java.io.IOException;


import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;


import io.swagger.v3.oas.annotations.ExternalDocumentation;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.info.License;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;

import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

import org.json.XML;

import pl.psnc.dl.ege.webapp.servlethelpers.Conversion;

/**
 * EGE RESTful WebService interface.
 * 
 * Conversion web service servlet, accepting requests in REST WS manner.
 * 
 * @author mariuszs
 */
/*
 * TODO : Metody tworzace XML wrzucic do osobnej klasy lub uzyc Apache Velocity.
 */
@OpenAPIDefinition(info =
@Info(
        title = "EGE Webservice",
        version = "1.0",
        description = "EGE Webservice API to convert and validate TEI related data.",
        license = @License(name = " GPL-3.0 license", url = "https://www.gnu.org/licenses/gpl-3.0.en.html"),
        contact = @Contact(url = "https://github.com/TEIC/TEIGarage", name = "Anne Ferger", email = "anne.ferger@upb.de")
), tags = {
        @Tag(name = "ege-webservice", description = "Conversion, Validation and Customization")
},
        externalDocs = @ExternalDocumentation(description = "find out more at GitHub", url = "https://github.com/TEIC/TEIGarage")
)
public class ConversionServlet extends HttpServlet {

	private static final String imagesDirectory = "media";

	private static final String EZP_EXT = ".ezp";

	private static final String FORMAT_DOCX = "docx";

	private static final String FORMAT_ODT = "oo";

	private static final String APPLICATION_MSWORD = "application/msword";

	private static final String APPLICATION_EPUB = "application/epub+zip";

	private static final String APPLICATION_ODT = "application/vnd.oasis.opendocument.text";

	private static final String APPLICATION_OCTET_STREAM = "application/octet-stream";

	private static final Logger LOGGER = LogManager.getLogger(ConversionServlet.class);

	private static final long serialVersionUID = 1L;

	public static final String SLASH = "/";

	public static final String COMMA = ",";

	public static final String SEMICOLON = ";";

	public static final String R_WRONG_METHOD = "Wrong method: GET, expected: POST.";

	public static final String CONVERSIONS_SLICE_BASE = "Conversions/";

	public static final String ZIP_EXT = ".zip";

	public static final String DOCX_EXT = ".docx";

	public static final String EPUB_EXT = ".epub";

	public static final String ODT_EXT = ".odt";

	Conversion conversion;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public ConversionServlet() {
		super();
		Conversion conversion = new Conversion();
	}

    /**
     * Serves GET requests - responses are : list of input data types and lists
     * of possible conversions paths.
     */
    @Override
    @GET
	@Path("ege-webservice/Conversions")
    @Operation(summary = "Get all available conversions", tags = "ege-webservice", description = "Return list of input data types and lists of possible conversions paths", responses = {
            @ApiResponse(
                    description = "List of possible conversions is returned",
                    responseCode = "200",
                    content = @Content(mediaType = "text/xml")),
            @ApiResponse(
                    description = "Wrong method error message if the method is called wrong",
                    responseCode = "405")
    })
    public void doGet(
            @Parameter(hidden = true) HttpServletRequest request,
            @Parameter(hidden = true) HttpServletResponse response) throws ServletException, IOException {
			conversion.doGetHelper(request, response);
		}


	/**
	 * Servers POST method - performs conversions over specified within URL
	 * conversions path.
	 */
    @Override
    @POST
	@Path("ege-webservice/Conversions/{input-document-type}/{output-document-type}")
    @Operation(summary = "Do conversions", tags = "ege-webservice", description = "Convert files into different data formats",
            parameters = {
                    @Parameter(
                            in = ParameterIn.QUERY,
                            description = "Conversion properties",
                            required = false,
                            name = "properties",
                            schema = @Schema(type= "string", format="text/xml")),
					@Parameter(
							in = ParameterIn.PATH,
							description = "Input document type",
							required = true,
							name = "input-document-type",
							schema = @Schema(type= "string", format="text/plain")),
					@Parameter(
							in = ParameterIn.PATH,
							description = "Output document type",
							required = true,
							name = "output-document-type",
							schema = @Schema(type= "string", format="text/plain"))
            },
            responses = {
                    @ApiResponse(
                            description = "The content of the converted file",
                            responseCode = "200",
							content = @Content(mediaType = "text/xml", schema = @Schema(implementation = XML.class))),
                    @ApiResponse(
                            description = "Wrong method error message if the method is called wrong",
                            responseCode = "405")
            })

    public void doPost(
            @Parameter(hidden = true) HttpServletRequest request,
            @Parameter(hidden = true) HttpServletResponse response) throws ServletException, IOException {
		conversion.doPostHelper(request, response);
	}

}

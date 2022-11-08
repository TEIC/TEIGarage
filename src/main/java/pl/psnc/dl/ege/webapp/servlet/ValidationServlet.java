package pl.psnc.dl.ege.webapp.servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;


import pl.psnc.dl.ege.types.DataType;
import pl.psnc.dl.ege.types.ValidationResult;

import pl.psnc.dl.ege.webapp.servlethelpers.Validation;

/**
 * Serves validation operations in RESTful WS manner.
 */
@OpenAPIDefinition(tags = {
		@Tag(name = "ege-webservice", description = "Conversion, Validation and Customization")
})
public class ValidationServlet
	extends HttpServlet
{

	private static final Logger LOGGER = LogManager
			.getLogger(ValidationServlet.class);

	private static final long serialVersionUID = 1L;

    Validation validation = new Validation();

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public ValidationServlet()
	{
		super();
	}


	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	@GET
	@Path("ege-webservice/Validation")
	@Operation(summary = "Get all available validations", tags = "ege-webservice", description = "Return list of input data types and lists of possible validation paths", responses = {
			@ApiResponse(
					description = "List of possible validations is returned",
					responseCode = "200",
					content = @Content(mediaType = "text/xml", schema = @Schema(implementation = DataType.class))),
			@ApiResponse(
					description = "Wrong method error message if the method is called wrong",
					responseCode = "405")
	})
	public void doGet(@Parameter(hidden = true) HttpServletRequest request,
					  @Parameter(hidden = true) HttpServletResponse response)
            throws ServletException, IOException {
        validation.doGetHelper(request, response);
			}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	@Override
	@POST
	@Path("ege-webservice/Validation/{input-document-type}")
	@Operation(summary = "Do validation", tags = "ege-webservice", description = "Validate files of different data formats",
			parameters = {
					@Parameter(
							in = ParameterIn.PATH,
							description = "Input document type",
							required = true,
							name = "input-document-type",
							schema = @Schema(implementation = DataType.class))
			},
			responses = {
					@ApiResponse(
							description = "Validation Result",
							responseCode = "200",
							content = @Content(mediaType = "text/xml", schema = @Schema(implementation = ValidationResult.class))),
					@ApiResponse(
							description = "Wrong method error message if the method is called wrong",
							responseCode = "405")
			})
	public void doPost(HttpServletRequest request,
			HttpServletResponse response)
            throws ServletException, IOException {
        validation.doPostHelper(request, response);
	}

}

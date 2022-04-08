package pl.psnc.dl.ege.webapp.request;

import javax.servlet.http.HttpServletRequest;

public class InfoRequestResolver extends RequestResolver{

    private static final String SLICE_BASE = "Info/";


    public InfoRequestResolver(HttpServletRequest request, Method method) throws RequestResolvingException{
        this.request = request;
        this.method = method;
        init();
    }

    private void init() throws RequestResolvingException{
        if(method.equals(Method.GET)){
            resolveGET();
        }
    }

    private void resolveGET() throws RequestResolvingException{
        String[] queries = resolveQueries();
        if(queries.length == 1){
            operation = OperationId.PRINT_VALIDATIONS;
        }
        else{
            throw new RequestResolvingException(RequestResolvingException.Status.WRONG_METHOD);
        }
    }

    private String[] resolveQueries()
    {
        String params = request.getRequestURL().toString();
        params = (params.endsWith(SLASH) ? params : params + SLASH);
        params = params.substring(params.indexOf(SLICE_BASE),
                params.length());
        String[] queries = params.split(SLASH);
        return queries;
    }


    @Override
    public String getLocale()
    {
        return null;
    }
}

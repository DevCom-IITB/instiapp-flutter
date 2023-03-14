package app.insti.api;


import java.util.List;

import app.insti.api.model.HostelMessMenu;
import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Header;


public interface RetrofitInterface {
    

    @GET("mess")
    Call<List<HostelMessMenu>> getInstituteMessMenu(@Header("Cookie") int sessionID);
}

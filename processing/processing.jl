using GRIB


keylist = Vector{String}()
grib_file = "/home/neo/Projekte/Predly/weather/gfs_workflow/download/data/gfs.20210109/06/gfs.t06z.pgrb2.0p25.f002"


parameters = [7,11,586,422,423,424,426,428,430,433,434,435,437,438,439,440,441,442,443,451,453,455,456,457,458,472,473,474,476,479,480,481,482,483,495,496,498,588]

unneeded_identifiers = ["values", "codedValues", "latLonValues", "latitudes", "longitudes", "distinctLatitudes", "distinctLongitudes"]

start_time = time()

data_dict = Dict()

GribFile(grib_file) do f    
    for (index, message) in enumerate(f)

        band_time = time()
        data_array = []
        parameter_name = message["parameterName"]
        parameter_unit = message["parameterUnits"]
        parameter_ecmf = message["nameECMF"]
        units_ecmf = message["unitsECMF"]
        name = message["name"]
        units = message["units"]
        level = message["level"]
        type_of_level = message["typeOfLevel"]
        short_name = message["shortName"]
        data_dict[index] = Dict()

        # calculate x/y raster from points where x == 2y - 2
        # x is 1440 here, y is 721, 1440x721=1038240
        number_points = message["numberOfDataPoints"]
        y =  round(sqrt(number_points/2), digits=0, RoundUp)
        x =  2 * y - 2

        lat0 = message["latitudeOfFirstGridPointInDegrees"]
        lon0 = message["longitudeOfFirstGridPointInDegrees"]
        lat1 = message["latitudeOfLastGridPointInDegrees"]
        lon1 = message["longitudeOfLastGridPointInDegrees"]

        if index in parameters

            data_dict[index]["latitudes"] = message["latitudes"]
            data_dict[index]["longitudes"] = message["longitudes"]
            data_dict[index]["values"] = message["values"]
                
            println("band ", index ," parameter name: ", parameter_name, " unit ", parameter_unit, 
                    " name ecmf ", parameter_ecmf, " units ecmf ", units_ecmf,
                    " name ", name, " units ", units, " level ", level,
                    " type of level ", type_of_level, " short name ", short_name)

            println(" x ",x, " y ", y, " num points ", number_points, " ", lat0 , " ", lon0, " ", lat1, " ", lon1)

            Nearest(message) do near

                lons, lats, values, distances = find(near, message, 8, 50)
                println(lons, lats, values, distances)

            end

            for key in keys(message)
                if key ∉ keylist
                    try
                       push!(keylist, key)
                    catch
                        print(key)
                    end
                end
            end
            
            println(length(data_array), " took ", time() - band_time)
        end
    end
    println("Overall time: ", time() - start_time)
end

println(Base.summarysize(data_dict)/1000000000, " Gigabytes ")
print(keylist)
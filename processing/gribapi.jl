using GRIB


keylist = Vector{String}()
grib_file = "/home/neo/Projekte/Predly/weather/gfs_workflow/download/data/gfs.20210109/06/gfs.t06z.pgrb2.0p25.f002"


parameters = [7,11,586,422,423,424,426,428,430,433,434,435,437,438,439,440,441,442,443,451,453,455,456,457,458,472,473,474,476,479,480,481,482,483,495,496,498,588]

unneeded_identifiers = ["values", "codedValues", "latLonValues", "latitudes", "longitudes", "distinctLatitudes", "distinctLongitudes"]


f = GribFile(grib_file)   

function getValue(f, band::Int64, lat::Float64, lon::Float64)

    start_time = time()

    for (index, message) in enumerate(f)

        band_time = time()
        data_array = []
        parameter_name = message["parameterName"]
        parameter_unit = message["parameterUnits"]
        parameter_ecmf = message["nameECMF"]
        units_ecmf     = message["unitsECMF"]
        name           = message["name"]
        units          = message["units"]
        level          = message["level"]
        type_of_level  = message["typeOfLevel"]
        short_name     = message["shortName"]
    
        if index == band    
    
            Nearest(message) do near
                lons, lats, values, distances = find(near, message, 8, 50)
                seek(f, 0)
                println("Took ", time()-start_time)
                println(lons,lats,values,distances)
                return lons, lats, values, distances
            end
        end
    end
    
end

getValue(f, 450, 50.0, 8.25)

destroy(f)
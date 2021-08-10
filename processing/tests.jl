using GRIB
grib_file = "/home/neo/Projekte/Predly/weather/gfs_workflow/download/data/gfs.20210109/06/gfs.t06z.pgrb2.0p25.f002"
function check_messages(grib_file)
    messages = 0
    GribFile(grib_file) do f    
        for message in f
            messages+=1
        end
    end
    println(messages)
end


function check_keys(grib_file)
    GribFile(grib_file) do f
        for message in f
            for key in keys(message)
                if key ∉ keylist
                push!(keylist, key)
                end
            end
        end
    end
end

check_messages(grib_file)
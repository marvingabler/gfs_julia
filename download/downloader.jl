using ConfParser
import Dates
using AWSCore
using AWS: @service
@service S3

# load config
conf = ConfParse("conf/config.ini")
parse_conf!(conf)
download_dir = retrieve(conf, "dirs", "download")
aws_bucket   = retrieve(conf, "data", "aws_bucket")
gfs_prefix   = retrieve(conf, "data", "gfs_prefix")
gfs_postfix  = retrieve(conf, "data", "gfs_postfix")


@doc """ Downloads all gfs files for given run from NOAA's AWS bucket
"""
function download_gfs_data(run::Int64)

    # build daily files array
    current_date = Dates.now()
    current_hour = Dates.format(current_date, "HH")
    current_date_string = "gfs." * Dates.format(current_date, "yyyymmdd")
    current_files = []

    if (length(string(run)) == 1) && run in [0, 6]
        run = "0" * string(run)
    elseif length(string(run)) == 2 && run in [12, 18]
        run = string(run)
    else
        throw(ArgumentError("run must be in [0,6,12,18]"))
    end

    for i in 0:120
        if length(string(i)) == 1
            i = lpad(string(i), 3, '0')
        elseif length(string(i)) == 2
            i = lpad(string(i), 3, '0')
        end
        # build path
        push!(current_files,joinpath(current_date_string,run,(gfs_prefix * string(run) * gfs_postfix * string(i))))
    end    

    for i in 120:3:384
        push!(current_files,joinpath(current_date_string,run,(gfs_prefix * string(run) * gfs_postfix * string(i))))
    end

    aws = aws_config()  

    current_dir = pwd()
    download_dir_path = joinpath(current_dir, download_dir)
    daily_dir_path = joinpath(download_dir_path, current_date_string)
    run_dir_path = joinpath(daily_dir_path, run)

    for dir in [download_dir_path, daily_dir_path, run_dir_path]
        if !isdir(dir)
            mkdir(dir)
        end
    end

    for file in current_files
        println("Downloading ", file)
        try
            file_name = file[end-24:end]
            file_path = download_dir_path * "/" * file # for any reason, joinpath does not work here

            if !isfile(file_path)
                s3_object = S3.get_object(aws_bucket, file)
                io = open(file_path,"w")
                write(io, s3_object)
                close(io)
            else
                println("File ", file, " already downloaded.")
            end

        catch
            println("Error at downloading", file)
        end
    end 
end

if abspath(PROGRAM_FILE) == @__FILE__

    if length(ARGS) == 0
        println("Please specify run to download with julia app.py [run::int in [0,6,12,18]]")
    elseif length(ARGS) == 1
        run = parse(Int,ARGS[1])
        if (length(string(run)) == 1) && run in [0, 6]
            download_gfs_data(run)
        elseif length(string(run)) == 2 && run in [12, 18]
            download_gfs_data(run)
        else
            throw(ArgumentError("run must be in [0,6,12,18]"))
        end   
    else
        throw(ArgumentError("Too many arguments"))
    end
end
{application,cowlib,
             [{description,"Support library for manipulating Web protocols."},
              {vsn,"1.3.0"},
              {id,"git"},
              {modules,[cow_cookie,cow_date,cow_http,cow_http_hd,cow_http_te,
                        cow_mimetypes,cow_multipart,cow_qs,cow_spdy,cow_ws]},
              {registered,[]},
              {applications,[kernel,stdlib,crypto]}]}.

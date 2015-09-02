cuda_lib = '/work/sdks/cudacurrent/lib64'
cuda_inc = '/work/sdks/cudacurrent/include'

if ismac
    cuda_lib = '/usr/local/cuda/lib';
    cuda_inc = '/usr/local/cuda/include';
end

unix('make -C ../build/');

if ismac
    eval(sprintf(['mex -largeArrayDims -output pdsolver ' ...
                  'CXXFLAGS=''\\$CXXFLAGS -O3 -stdlib=libstdc++ -std=c++11'' '...
                  'LDFLAGS=''\\$LDFLAGS -stdlib=libstdc++ -Wl,-rpath,%s'' '...
                  'pdsolver_mex.cpp factory_mex.cpp ../build/libpdsolver.a' ...
                  ' -L%s -I%s -lcudart -lcublas -lcusparse' ], ...
                 cuda_lib, cuda_lib, cuda_inc))
else
    eval(sprintf(['mex -largeArrayDims -output pdsolver ' ...
                  'CXXFLAGS=''\\$CXXFLAGS -O3'' '...
                  'LDFLAGS=''\\$LDFLAGS -Wl,-rpath,%s'' '...
                  'pdsolver_mex.cpp factory_mex.cpp ../build/libpdsolver.a' ...
                  ' -L%s -I%s -lcudart -lcublas -lcusparse' ], ...
                 cuda_lib, cuda_lib, cuda_inc))
end

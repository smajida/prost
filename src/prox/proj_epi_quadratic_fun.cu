#include "prox/proj_epi_quadratic_fun.hpp"

#include <iostream>
#include <sstream>

#include "prox/vector.hpp"

#include "config.hpp"
#include "exception.hpp"


template<typename T>
struct Coefficients {
  const T* dev_a;
  const T* dev_b;
  const T* dev_c;


  T a;
  T c;
};

template<typename T>
__global__
void ProjEpiQuadraticFunKernel(
  T *d_res,
  const T *d_arg,
  size_t count,
  size_t dim,
  Coefficients<T> coeffs)
{
  size_t tx = threadIdx.x + blockDim.x * blockIdx.x;

  if(tx < count)
  {

    Vector<T> x(count, dim-1, true, tx, d_res);
    const Vector<T> x0(count, dim-1, true, tx, d_arg);
    T& y = d_res[count * (dim-1) + tx];
    const T y0 = d_arg[count * (dim-1) + tx];

    const T a = coeffs.dev_a == nullptr ? coeffs.a : coeffs.dev_a[tx];
    const Vector<T> b(coeffs.dev_b == nullptr ? 1 : count, dim-1, true, coeffs.dev_b == nullptr ? 0 : tx, coeffs.dev_b);
    const T c = coeffs.dev_c == nullptr ? coeffs.c : coeffs.dev_c[tx];


    T sq_norm_b = static_cast<T>(0);
    for(size_t i = 0; i < dim-1; i++) {
      T val = b[i];
      x[i] = x0[i] + val / a;
      sq_norm_b += val * val;
    }
    

    ProjEpiQuadraticFun<T>::ProjectSimple(x, y0 / a + (0.5 / (a*a)) * sq_norm_b - c / a, 0.5, x, y, dim-1);
      
    for(size_t i = 0; i < dim-1; i++) {
      x[i] -= b[i] / a;
    }

    y = y * a - (0.5 / a) * sq_norm_b + c;
  }
}


template<typename T>
void 
ProjEpiQuadraticFun<T>::EvalLocal(
  const typename thrust::device_vector<T>::iterator& result_beg,
  const typename thrust::device_vector<T>::iterator& result_end,
  const typename thrust::device_vector<T>::const_iterator& arg_beg,
  const typename thrust::device_vector<T>::const_iterator& arg_end,
  const typename thrust::device_vector<T>::const_iterator& tau_beg,
  const typename thrust::device_vector<T>::const_iterator& tau_end,
  T tau,
  bool invert_tau)
{
  dim3 block(kBlockSizeCUDA, 1, 1);
  dim3 grid((this->count_ + block.x - 1) / block.x, 1, 1);

  Coefficients<T> coeffs;
  if(a_.size() != 1) {
    coeffs.dev_a = thrust::raw_pointer_cast(&(d_a_[0]));
  } else {
    coeffs.dev_a = nullptr;
    coeffs.a = a_[0];
  }

  coeffs.dev_b = thrust::raw_pointer_cast(&(d_b_[0]));


  if(c_.size() != 1) {
    coeffs.dev_c = thrust::raw_pointer_cast(&(d_c_[0]));
  } else {
    coeffs.dev_c = nullptr;
    coeffs.c = c_[0];
  }

  ProjEpiQuadraticFunKernel<T>
    <<<grid, block>>>(
      thrust::raw_pointer_cast(&(*result_beg)),
      thrust::raw_pointer_cast(&(*arg_beg)),
      this->count_,
      this->dim_,
      coeffs);
  cudaDeviceSynchronize();

  // check for error
  cudaError_t error = cudaGetLastError();
  if(error != cudaSuccess)
  {
    // print the CUDA error message and throw exception
    std::stringstream ss;
    ss << "CUDA error: " << cudaGetErrorString(error) << std::endl;
    throw Exception(ss.str());
  }
}

template<typename T>
void
ProjEpiQuadraticFun<T>::Initialize() 
{
    if(a_.size() != this->count_ && a_.size() != 1)
      throw Exception("Wrong input: Coefficient a has to have dimension count or 1!");

    for(T& a : a_) {
      if(a <= 0)
        throw Exception("Wrong input: Coefficient a must be greater 0!");
    }

    if(b_.size() != this->count_*(this->dim_-1) && b_.size() != this->dim_-1)
      throw Exception("Wrong input: Coefficient b has to have dimension count*(dim-1) or dim-1!");

    if(c_.size() != this->count_ && c_.size() != 1)
      throw Exception("Wrong input: Coefficient c has to have dimension count or 1!");

    try
    {
      d_a_.resize(a_.size());
      thrust::copy(a_.begin(), a_.end(), d_a_.begin());
      d_b_.resize(b_.size());
      thrust::copy(b_.begin(), b_.end(), d_b_.begin());
      d_c_.resize(c_.size());
      thrust::copy(c_.begin(), c_.end(), d_c_.begin());
    }
    catch(std::bad_alloc &e)
    {
      throw Exception(e.what());
    }
    catch(thrust::system_error &e)
    {
      throw Exception(e.what());
    }
    
}

// Explicit template instantiation
template class ProjEpiQuadraticFun<float>;
template class ProjEpiQuadraticFun<double>;
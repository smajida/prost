#ifndef FACTORY_MEX_HPP_
#define FACTORY_MEX_HPP_

#include "mex.h"

#include "config.hpp"
#include "solver/solver.hpp"
#include "util/sparse_matrix.hpp"

// forward declarations
template<typename T> class Prox;
template<typename T> class Prox1D;
template<typename T> class ProxNorm2;
template<typename T> class ProxEpiConjQuadr;
template<typename T> class ProxMoreau;
template<typename T> class ProxSimplex;
template<typename T> class ProxZero;

// linops
template<typename T> class LinOp;
template<typename T> class LinearOperator;
template<typename T> class LinOpIdentity;
template<typename T> class LinOpGradient2D;
template<typename T> class LinOpGradient3D;
template<typename T> class LinOpSparse;
template<typename T> class LinOpDataPrec;

// individual prox constructors
Prox1D<real>* Prox1DFromMatlab(int idx, int count, const mxArray *data);
ProxNorm2<real>* ProxNorm2FromMatlab(int idx, int count, int dim, bool interleaved, const mxArray *data);
ProxEpiConjQuadr<real>* ProxEpiConjQuadrFromMatlab(int idx, int count, bool interleaved, const mxArray *data);
ProxMoreau<real>* ProxMoreauFromMatlab(const mxArray *data);
ProxSimplex<real>* ProxSimplexFromMatlab(int idx, int count, int dim, bool interleaved, const mxArray *data);
ProxZero<real>* ProxZeroFromMatlab(int idx, int count);

Prox<real>* ProxFromMatlab(const mxArray *pm);
SparseMatrix<real>* MatrixFromMatlab(const mxArray *pm);
void SolverOptionsFromMatlab(const mxArray *pm, SolverOptions& opts, mxArray **cb_func_handle);

LinearOperator<real>* LinearOperatorFromMatlab(const mxArray *pm);
LinOpIdentity<real>* LinOpIdentityFromMatlab(size_t row, size_t col, const mxArray *pm);
LinOpSparse<real>* LinOpSparseFromMatlab(size_t row, size_t col, const mxArray *pm);
LinOpGradient2D<real>* LinOpGradient2DFromMatlab(size_t row, size_t col, const mxArray *pm);
LinOpGradient3D<real>* LinOpGradient3DFromMatlab(size_t row, size_t col, const mxArray *pm);
LinOp<real>* LinOpZeroFromMatlab(size_t row, size_t col, const mxArray *pm);
LinOpDataPrec<real>* LinOpDataPrecFromMatlab(size_t row, size_t col, const mxArray *pm);

#endif

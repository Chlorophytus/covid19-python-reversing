from libc.stdlib cimport malloc, free
from cpython cimport Py_buffer

import math

cdef extern from "x86intrin.h" nogil:
    ctypedef struct __m256i:
        pass

    void *_mm_malloc(size_t size, size_t align)
    void _mm_free(void *mem_addr)

    __m256i _mm256_stream_load_si256(__m256i *mem_addr)

cdef class VectorizedGenomeParser:
    # Sparsely packed to speed up processing
    parse = {
        'A': 1,
        'C': 2,
        'G': 4,
        'T': 8,
    }

    cdef __m256i *vectors
    cdef size_t size

    def __init__(self, str data):
        self.size = math.ceil(len(data) / 32)
        cdef aligned_size = self.size * 32
        cdef char *aligned = <char *>_mm_malloc(aligned_size, 32)
        point_stride = None
        for n, point in enumerate(data):
            aligned[n] = self.parse[point]
            point_stride = n
        
        while point_stride != aligned_size:
            aligned[point_stride] = <char>0
            point_stride += 1

        # Source AND dest must be 32-aligned?!
        self.vectors = <__m256i *>_mm_malloc(sizeof(__m256i) * self.size, 32)
        for i in range(self.size):
            self.vectors[i] = _mm256_stream_load_si256(<__m256i *>&(aligned[i * 32]))
        
        _mm_free(aligned)


    def __getbuffer__(self, Py_buffer *view, int flags):
        view.buf = self.vectors
        view.len = self.size * 32
        view.readonly = 1
        view.format = '<32b'
        view.ndim = 1
        view.shape[0] = self.size
        view.strides = NULL
        view.suboffsets = NULL
        view.itemsize = 32
        view.internal = NULL

    def __releasebuffer__(self, Py_buffer *view):
        pass
    
    def __dealloc__(self):
        _mm_free(self.vectors)


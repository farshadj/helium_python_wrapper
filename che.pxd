# file: che.pxd



from libc.stdint cimport uint32_t, uint64_t

cdef extern from "he.h":


    #ifndef _HE_H
    #define _HE_H

    #include <stddef.h>
    #include <stdint.h>


    #define HE_VERSION_MAJOR              2
    #define HE_VERSION_MINOR              8
    #define HE_VERSION_PATCH              2

    #define HE_MAX_DATASTORES          4095
    #define HE_MAX_KEY_LEN            65535
    #define HE_MAX_VAL_LEN         16777215

    #define HE_O_CREATE                   1
    #define HE_O_TRUNCATE                 2
    #define HE_O_VOLUME_CREATE            4
    #define HE_O_VOLUME_TRUNCATE          8
    #define HE_O_VOLUME_NOTRIM           16
    #define HE_O_NOSORT                  32
    #define HE_O_SCAN                    64
    #define HE_O_CLEAN                  128
    #define HE_O_COMPRESS               256

    #define HE_ERR_SOFTWARE            -100
    #define HE_ERR_ARGUMENTS           -101
    #define HE_ERR_MEMORY              -102
    #define HE_ERR_CHECKSUM            -103
    #define HE_ERR_TERMINATED          -104
    #define HE_ERR_UNSUPPORTED         -105
    #define HE_ERR_DEVICE_STAT         -106
    #define HE_ERR_DEVICE_OPEN         -107
    #define HE_ERR_DEVICE_ACCESS       -108
    #define HE_ERR_DEVICE_LOCK         -109
    #define HE_ERR_DEVICE_GEOMETRY     -110
    #define HE_ERR_DEVICE_READ         -111
    #define HE_ERR_DEVICE_WRITE        -112
    #define HE_ERR_VOLUME_TOO_SMALL    -113
    #define HE_ERR_VOLUME_INVALID      -114
    #define HE_ERR_VOLUME_CORRUPT      -115
    #define HE_ERR_VOLUME_IN_USE       -116
    #define HE_ERR_VOLUME_FULL         -117
    #define HE_ERR_DATASTORE_NOT_FOUND -118
    #define HE_ERR_DATASTORE_EXISTS    -119
    #define HE_ERR_DATASTORE_IN_USE    -120
    #define HE_ERR_ITEM_NOT_FOUND      -121
    #define HE_ERR_ITEM_EXISTS         -122
    #define HE_ERR_NETWORK_LISTEN      -123
    #define HE_ERR_NETWORK_ACCEPT      -124
    #define HE_ERR_NETWORK_CONNECT     -125
    #define HE_ERR_NETWORK_READ        -126
    #define HE_ERR_NETWORK_WRITE       -127
    #define HE_ERR_NETWORK_PROTOCOL    -128

    cdef struct he_env:
        uint64_t fanout             # count */
        uint64_t write_cache        # bytes */
        uint64_t read_cache         # bytes */
        uint64_t auto_commit_period # sec   */
        uint64_t auto_clean_period  # sec   */
        uint64_t clean_util_pct    # %     */
        uint64_t clean_dirty_pct    # %     */
        uint64_t retry_count        # count */
        uint64_t retry_delay        # usec  */
    

    cdef struct he_stats:
        const char *name
        uint64_t valid_items     # count 
        uint64_t deleted_items   # count 
        uint64_t utilized        # bytes 
        uint64_t capacity        # bytes 
        uint64_t buffered_writes # bytes
        uint64_t buffered_reads  # bytes 
        uint64_t device_writes   # bytes 
        uint64_t device_reads    # bytes 
        uint64_t auto_commits    # count 
        uint64_t auto_cleans    # count 
    

   
    cdef struct he_item:
        void *key
        void *val
        size_t key_len
        size_t val_len
    

    ctypedef void *he_t;
    ctypedef int (*he_enumerate_cbf_t)(void *arg, const char *name);
    ctypedef int (*he_iterate_cbf_t)(void *arg, const he_item*  *item);
    int he_is_valid(const he_t he);
    int he_is_transaction(const he_t he);

    int he_enumerate(const char *url, he_enumerate_cbf_t cbf, void *arg);

    he_t he_open(const char *url,
             const char *name,
             int flags,
             const he_env *env);
             
             
    int he_close(he_t he);
    int he_remove(he_t he);
    int he_rename(he_t he, const char *name);
    int he_stats(he_t he,  he_stats *stats);

    he_t he_transaction(he_t he);
    int he_commit(he_t he);
    int he_discard(he_t he);

    int he_update(he_t he, const he_item *item);
    int he_insert(he_t he, const he_item *item);
    int he_replace(he_t he, const he_item *item);
    int he_delete(he_t he, const he_item *item);
    int he_delete_lookup(he_t he,he_item *item, size_t off, size_t len);

    int he_exists(he_t he, const he_item *item);
    int he_lookup(he_t he,  he_item *item, size_t off, size_t len);
    int he_next(he_t he,  he_item *item, size_t off, size_t len);
    int he_prev(he_t he,  he_item *item, size_t off, size_t len);
    int he_iterate(he_t he, he_iterate_cbf_t cbf, void *arg);

    void he_perror(const char *s);
    const char *he_strerror(int err);
    const char *he_version(int *major, int *minor, int *patch);


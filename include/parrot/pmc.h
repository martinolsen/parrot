/* pmc.h
 *  Copyright: (When this is determined...it will go here)
 *  CVS Info
 *     $Id$
 *  Overview:
 *     This is the api header for the pmc subsystem
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#if !defined(PARROT_PMC_H_GUARD)
#define PARROT_PMC_H_GUARD

enum {
    enum_class_Array,
    enum_class_PerlUndef,
    enum_class_PerlInt,
    enum_class_PerlNum,
    enum_class_PerlString,
    enum_class_PerlArray,
    enum_class_PerlHash,
    enum_class_ParrotPointer,
    enum_class_IntQueue,
    enum_class_max = 100
};
VAR_SCOPE VTABLE Parrot_base_vtables[enum_class_max];
VAR_SCOPE PMC *Parrot_base_classname_hash;

struct PMC {
  VTABLE *vtable;
  INTVAL flags;
  DPOINTER *data;
  union {
    INTVAL int_val;
    FLOATVAL num_val;
    DPOINTER *struct_val;
  } cache;
  SYNC *synchronize;
};

/* PMC flag bits */

typedef enum {
    /* the first 8 bits are for private use by individual vtable
     * classes. It is suggested that you alias these within an individual
     * class's header file
     */
    PMC_private0_FLAG   = 1 << 0,
    PMC_private1_FLAG   = 1 << 1,
    PMC_private2_FLAG   = 1 << 2,
    PMC_private3_FLAG   = 1 << 3,
    PMC_private4_FLAG   = 1 << 4,
    PMC_private5_FLAG   = 1 << 5,
    PMC_private6_FLAG   = 1 << 6,
    PMC_private7_FLAG   = 1 << 7,

    /* The rest of the flags are for use by Parrot */

    /* Set if the PMC has a destroy method that must be called */
    PMC_active_destroy_FLAG = 1 << 8,
    /* Set if the PMC can hold multiple PMCs. (Hash, array, list,
       whatever) */
    PMC_is_container_FLAG   = 1 << 9,
    /* Set to true if the PMC data pointer points to something that
       looks like a string or buffer pointer */
    PMC_is_buffer_ptr_FLAG  = 1 << 10,
    /* Set to true if the data pointer points to a PMC */
    PMC_is_PMC_ptr_FLAG     = 1 << 11,
    /* Set to true if the PMC has a private GC function. For PMCs the
       GC system can't snoop into */
    PMC_private_GC_FLAG     = 1 << 12
} PMC_flags;

/* XXX add various bit test macros once we have need of them */

/* Prototypes */
PMC* pmc_new(struct Parrot_Interp *interpreter, INTVAL base_type);

#endif

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil 
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/

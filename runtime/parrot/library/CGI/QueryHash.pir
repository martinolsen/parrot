# Copyright (C) 2006, The Perl Foundation.
# $Id$

.namespace ['CGI'; 'QueryHash']

=head1 NAME

['CGI' ; 'QueryHash'] - A helper for classic CGI 

=head1 SYNOPSIS

  load_bytecode 'CGI/QueryHash.pbc'

=head2 Functions

=over

=item parse_get

Get parameters for GET method.

=cut


.sub 'parse_get' 

    .local pmc my_env, query_hash, items, items_tmp_1, items_tmp_2
    .local string query, kv, k, v, item_tmp_1, item_tmp_2
    .local int i, j, n, o

    query_hash      = new .Hash
    my_env          = new .Env
    query           = my_env['QUERY_STRING']
    items           = new .ResizableStringArray

    # split by '&' and ';'
    items_tmp_1 = split ';', query
    i = 0
    n = elements items_tmp_1
next_loop_1:
       if i >= n goto end_loop_1
       item_tmp_1 = items_tmp_1[i]
       inc i
       items_tmp_2 = split '&', item_tmp_1  
       j = 0
       o = elements items_tmp_2
next_loop_2:
           if j >= o goto next_loop_1
           item_tmp_2 = items_tmp_2[j]
           push items, item_tmp_2
           inc j
           goto next_loop_2
end_loop_1:

    i = 0
    n = elements items
lp_items:
    kv = items[i]
    $I0 = index kv, "="
    if $I0 == -1 goto no_val
    k = substr kv, 0, $I0
    k = urldecode(k)
    inc $I0
    v = substr kv, $I0
    goto set_val
no_val:
    k = kv
    v = 1
set_val:
    k = urldecode(k)
    query_hash[k] = v

next_item:
    inc i
    if i < n goto lp_items
    
    .return (query_hash)
.end

=head2 urldecode

convert %xx to char 

=cut

.sub urldecode
    .param string in

    .local string out, char_in, char_out
    .local int    c_out, pos_in, len
    .local string hex

    len = length in
    pos_in = 0
    out = ""
START:
    if pos_in >= len goto END
    substr char_in, in, pos_in, 1
    char_out = char_in
    if char_in != "%" goto INC_IN
    # OK this was a escape character, next two are hexadecimal
    inc pos_in
    substr hex, in, pos_in, 2
    c_out = hex_to_int (hex)
    chr char_out, c_out
    inc pos_in

INC_IN:
    concat out, char_out
    inc pos_in
    goto START
END:
   .return( out )
.end

.sub hex_to_int
    .param pmc hex
    .return hex.'to_int'(16)
.end

=back

=head1 HISTORY

Splitting of query string is taken from HTTP/Daemon.pir.

=head1 TODO

Add stuff that Plumhead needs.
Find or write a test suite for CGI.

=head1 SEE ALSO

F<runtime/parrot/library/HTTP/Daemon.pir>,
F<languages/plumhead/plumhead.pir>, F<t/library/cgi_query_hash.t>,
L<http://hoohoo.ncsa.uiuc.edu/cgi/overview.html>

=head1 AUTHOR

Bernhard Schmalhofer - <Bernhard.Schmalhofer@gmx.de> 

=cut


// Locale support -*- C++ -*-
// gcc-3.4.6/libstdc++-v3/include/bits/locale_facets.h

// Copyright (C) 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005
// Free Software Foundation, Inc.
//
// This file is part of the GNU ISO C++ Library.  This library is free
// software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the
// Free Software Foundation; either version 2, or (at your option)
// any later version.

// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License along
// with this library; see the file COPYING.  If not, write to the Free
// Software Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307,
// USA.

// As a special exception, you may use this file as part of a free software
// library without restriction.  Specifically, if other files instantiate
// templates or use macros or inline functions from this file, or you compile
// this file and link it with other files to produce an executable, this
// file does not by itself cause the resulting executable to be covered by
// the GNU General Public License.  This exception does not however
// invalidate any other reasons why the executable file might be covered by
// the GNU General Public License.

//
// ISO C++ 14882: 22.1  Locales
//

/** @file locale_facets.h
 *  This is an internal header file, included by other library headers.
 *  You should not attempt to use it directly.
 */

#ifndef _LOCALE_FACETS_H
#define _LOCALE_FACETS_H 1

#pragma GCC system_header

#include <ctime>	// For struct tm
#include <cwctype>	// For wctype_t
#include <iosfwd>
#include <bits/ios_base.h>  // For ios_base, ios_base::iostate
#include <streambuf>

namespace std
{
  // NB: Don't instantiate required wchar_t facets if no wchar_t support.
#ifdef _GLIBCXX_USE_WCHAR_T
# define  _GLIBCXX_NUM_FACETS 28
#else
# define  _GLIBCXX_NUM_FACETS 14
#endif

  // Convert string to numeric value of type _Tv and store results.
  // NB: This is specialized for all required types, there is no
  // generic definition.
  template<typename _Tv>
    void
    __convert_to_v(const char* __in, _Tv& __out, ios_base::iostate& __err,
		   const __c_locale& __cloc);

  // Explicit specializations for required types.
  template<>
    void
    __convert_to_v(const char*, float&, ios_base::iostate&,
		   const __c_locale&);

  template<>
    void
    __convert_to_v(const char*, double&, ios_base::iostate&,
		   const __c_locale&);

  template<>
    void
    __convert_to_v(const char*, long double&, ios_base::iostate&,
		   const __c_locale&);

  // NB: __pad is a struct, rather than a function, so it can be
  // partially-specialized.
  template<typename _CharT, typename _Traits>
    struct __pad
    {
      static void
      _S_pad(ios_base& __io, _CharT __fill, _CharT* __news,
	     const _CharT* __olds, const streamsize __newlen,
	     const streamsize __oldlen, const bool __num);
    };

  // Used by both numeric and monetary facets.
  // Inserts "group separator" characters into an array of characters.
  // It's recursive, one iteration per group.  It moves the characters
  // in the buffer this way: "xxxx12345" -> "12,345xxx".  Call this
  // only with __glen != 0.
  template<typename _CharT>
    _CharT*
    __add_grouping(_CharT* __s, _CharT __sep,
		   const char* __gbeg, size_t __gsize,
		   const _CharT* __first, const _CharT* __last);

  // This template permits specializing facet output code for
  // ostreambuf_iterator.  For ostreambuf_iterator, sputn is
  // significantly more efficient than incrementing iterators.
  template<typename _CharT>
    inline
    ostreambuf_iterator<_CharT>
    __write(ostreambuf_iterator<_CharT> __s, const _CharT* __ws, int __len)
    {
      __s._M_put(__ws, __len);
      return __s;
    }

  // This is the unspecialized form of the template.
  template<typename _CharT, typename _OutIter>
    inline
    _OutIter
    __write(_OutIter __s, const _CharT* __ws, int __len)
    {
      for (int __j = 0; __j < __len; __j++, ++__s)
	*__s = __ws[__j];
      return __s;
    }


  // 22.2.1.1  Template class ctype
  // Include host and configuration specific ctype enums for ctype_base.
  #include <bits/ctype_base.h>

  // Common base for ctype<_CharT>.
  /**
   *  @brief  Common base for ctype facet
   *
   *  This template class provides implementations of the public functions
   *  that forward to the protected virtual functions.
   *
   *  This template also provides abtract stubs for the protected virtual
   *  functions.
  */
  template<typename _CharT>
    class __ctype_abstract_base : public locale::facet, public ctype_base
    ;

  // NB: Generic, mostly useless implementation.
  /**
   *  @brief  Template ctype facet
   *
   *  This template class defines classification and conversion functions for
   *  character sets.  It wraps <cctype> functionality.  Ctype gets used by
   *  streams for many I/O operations.
   *
   *  This template provides the protected virtual functions the developer
   *  will have to replace in a derived class or specialization to make a
   *  working facet.  The public functions that access them are defined in
   *  __ctype_abstract_base, to allow for implementation flexibility.  See
   *  ctype<wchar_t> for an example.  The functions are documented in
   *  __ctype_abstract_base.
   *
   *  Note: implementations are provided for all the protected virtual
   *  functions, but will likely not be useful.
  */
  template<typename _CharT>
    class ctype : public __ctype_abstract_base<_CharT>
    ;

  template<typename _CharT>
    locale::id ctype<_CharT>::id;

  // 22.2.1.3  ctype<char> specialization.
  /**
   *  @brief  The ctype<char> specialization.
   *
   *  This class defines classification and conversion functions for
   *  the char type.  It gets used by char streams for many I/O
   *  operations.  The char specialization provides a number of
   *  optimizations as well.
  */
  template<>
    class ctype<char> : public locale::facet, public ctype_base
    ;

  template<>
    const ctype<char>&
    use_facet<ctype<char> >(const locale& __loc);

#ifdef _GLIBCXX_USE_WCHAR_T
  // 22.2.1.3  ctype<wchar_t> specialization
  /**
   *  @brief  The ctype<wchar_t> specialization.
   *
   *  This class defines classification and conversion functions for the
   *  wchar_t type.  It gets used by wchar_t streams for many I/O operations.
   *  The wchar_t specialization provides a number of optimizations as well.
   *
   *  ctype<wchar_t> inherits its public methods from
   *  __ctype_abstract_base<wchar_t>.
  */
  template<>
    class ctype<wchar_t> : public __ctype_abstract_base<wchar_t>
    ;

  template<>
    const ctype<wchar_t>&
    use_facet<ctype<wchar_t> >(const locale& __loc);
#endif //_GLIBCXX_USE_WCHAR_T

  // Include host and configuration specific ctype inlines.
  #include <bits/ctype_inline.h>

  // 22.2.1.2  Template class ctype_byname
  template<typename _CharT>
    class ctype_byname : public ctype<_CharT>
    ;

  // 22.2.1.4  Class ctype_byname specializations.
  template<>
    ctype_byname<char>::ctype_byname(const char*, size_t refs);

  template<>
    ctype_byname<wchar_t>::ctype_byname(const char*, size_t refs);

  // 22.2.1.5  Template class codecvt
  #include <bits/codecvt.h>

  // 22.2.2  The numeric category.
  class __num_base
  ;

  template<typename _CharT>
    struct __numpunct_cache : public locale::facet
    ;

  template<typename _CharT>
    __numpunct_cache<_CharT>::~__numpunct_cache()

  /**
   *  @brief  Numpunct facet.
   *
   *  This facet stores several pieces of information related to printing and
   *  scanning numbers, such as the decimal point character.  It takes a
   *  template parameter specifying the char type.  The numpunct facet is
   *  used by streams for many I/O operations involving numbers.
   *
   *  The numpunct template uses protected virtual functions to provide the
   *  actual results.  The public accessors forward the call to the virtual
   *  functions.  These virtual functions are hooks for developers to
   *  implement the behavior they require from a numpunct facet.
  */
  template<typename _CharT>
    class numpunct : public locale::facet
    ;

  template<typename _CharT>
    locale::id numpunct<_CharT>::id;

  template<>
    numpunct<char>::~numpunct();

  template<>
    void
    numpunct<char>::_M_initialize_numpunct(__c_locale __cloc);

#ifdef _GLIBCXX_USE_WCHAR_T
  template<>
    numpunct<wchar_t>::~numpunct();

  template<>
    void
    numpunct<wchar_t>::_M_initialize_numpunct(__c_locale __cloc);
#endif

  template<typename _CharT>
    class numpunct_byname : public numpunct<_CharT>
    ;

  /**
   *  @brief  Facet for parsing number strings.
   *
   *  This facet encapsulates the code to parse and return a number
   *  from a string.  It is used by the istream numeric extraction
   *  operators.
   *
   *  The num_get template uses protected virtual functions to provide the
   *  actual results.  The public accessors forward the call to the virtual
   *  functions.  These virtual functions are hooks for developers to
   *  implement the behavior they require from the num_get facet.
  */
  template<typename _CharT, typename _InIter>
    class num_get : public locale::facet
    ;

  template<typename _CharT, typename _InIter>
    locale::id num_get<_CharT, _InIter>::id;


  /**
   *  @brief  Facet for converting numbers to strings.
   *
   *  This facet encapsulates the code to convert a number to a string.  It is
   *  used by the ostream numeric insertion operators.
   *
   *  The num_put template uses protected virtual functions to provide the
   *  actual results.  The public accessors forward the call to the virtual
   *  functions.  These virtual functions are hooks for developers to
   *  implement the behavior they require from the num_put facet.
  */
  template<typename _CharT, typename _OutIter>
    class num_put : public locale::facet
    ;

  template <typename _CharT, typename _OutIter>
    locale::id num_put<_CharT, _OutIter>::id;


  /**
   *  @brief  Facet for localized string comparison.
   *
   *  This facet encapsulates the code to compare strings in a localized
   *  manner.
   *
   *  The collate template uses protected virtual functions to provide
   *  the actual results.  The public accessors forward the call to
   *  the virtual functions.  These virtual functions are hooks for
   *  developers to implement the behavior they require from the
   *  collate facet.
  */
  template<typename _CharT>
    class collate : public locale::facet
    ;

  template<typename _CharT>
    locale::id collate<_CharT>::id;

  // Specializations.
  template<>
    int
    collate<char>::_M_compare(const char*, const char*) const;

  template<>
    size_t
    collate<char>::_M_transform(char*, const char*, size_t) const;

#ifdef _GLIBCXX_USE_WCHAR_T
  template<>
    int
    collate<wchar_t>::_M_compare(const wchar_t*, const wchar_t*) const;

  template<>
    size_t
    collate<wchar_t>::_M_transform(wchar_t*, const wchar_t*, size_t) const;
#endif

  template<typename _CharT>
    class collate_byname : public collate<_CharT>
    ;


  /**
   *  @brief  Time format ordering data.
   *
   *  This class provides an enum representing different orderings of day,
   *  month, and year.
  */
  class time_base
  ;

  template<typename _CharT>
    struct __timepunct_cache : public locale::facet
    ;

  template<typename _CharT>
    __timepunct_cache<_CharT>::~__timepunct_cache()

  // Specializations.
  template<>
    const char*
    __timepunct_cache<char>::_S_timezones[14];

#ifdef _GLIBCXX_USE_WCHAR_T
  template<>
    const wchar_t*
    __timepunct_cache<wchar_t>::_S_timezones[14];
#endif

  // Generic.
  template<typename _CharT>
    const _CharT* __timepunct_cache<_CharT>::_S_timezones[14];

  template<typename _CharT>
    class __timepunct : public locale::facet
    ;

  template<typename _CharT>
    locale::id __timepunct<_CharT>::id;

  // Specializations.
  template<>
    void
    __timepunct<char>::_M_initialize_timepunct(__c_locale __cloc);

  template<>
    void
    __timepunct<char>::_M_put(char*, size_t, const char*, const tm*) const;

#ifdef _GLIBCXX_USE_WCHAR_T
  template<>
    void
    __timepunct<wchar_t>::_M_initialize_timepunct(__c_locale __cloc);

  template<>
    void
    __timepunct<wchar_t>::_M_put(wchar_t*, size_t, const wchar_t*,
				 const tm*) const;
#endif

  // Include host and configuration specific timepunct functions.
  #include <bits/time_members.h>

  /**
   *  @brief  Facet for parsing dates and times.
   *
   *  This facet encapsulates the code to parse and return a date or
   *  time from a string.  It is used by the istream numeric
   *  extraction operators.
   *
   *  The time_get template uses protected virtual functions to provide the
   *  actual results.  The public accessors forward the call to the virtual
   *  functions.  These virtual functions are hooks for developers to
   *  implement the behavior they require from the time_get facet.
  */
  template<typename _CharT, typename _InIter>
    class time_get : public locale::facet, public time_base
    ;

  template<typename _CharT, typename _InIter>
    locale::id time_get<_CharT, _InIter>::id;

  template<typename _CharT, typename _InIter>
    class time_get_byname : public time_get<_CharT, _InIter>
    {
    public:
      // Types:
      typedef _CharT			char_type;
      typedef _InIter			iter_type;

      explicit
      time_get_byname(const char*, size_t __refs = 0)
      : time_get<_CharT, _InIter>(__refs) { }

    protected:
      virtual
      ~time_get_byname() { }
    };

  /**
   *  @brief  Facet for outputting dates and times.
   *
   *  This facet encapsulates the code to format and output dates and times
   *  according to formats used by strftime().
   *
   *  The time_put template uses protected virtual functions to provide the
   *  actual results.  The public accessors forward the call to the virtual
   *  functions.  These virtual functions are hooks for developers to
   *  implement the behavior they require from the time_put facet.
  */
  template<typename _CharT, typename _OutIter>
    class time_put : public locale::facet
    ;

  template<typename _CharT, typename _OutIter>
    locale::id time_put<_CharT, _OutIter>::id;

  template<typename _CharT, typename _OutIter>
    class time_put_byname : public time_put<_CharT, _OutIter>
    ;


  /**
   *  @brief  Money format ordering data.
   *
   *  This class contains an ordered array of 4 fields to represent the
   *  pattern for formatting a money amount.  Each field may contain one entry
   *  from the part enum.  symbol, sign, and value must be present and the
   *  remaining field must contain either none or space.  @see
   *  moneypunct::pos_format() and moneypunct::neg_format() for details of how
   *  these fields are interpreted.
  */
  class money_base
  ;

  template<typename _CharT, bool _Intl>
    struct __moneypunct_cache : public locale::facet
    {
      const char*			_M_grouping;
      size_t                            _M_grouping_size;
      bool				_M_use_grouping;
      _CharT				_M_decimal_point;
      _CharT				_M_thousands_sep;
      const _CharT*			_M_curr_symbol;
      size_t                            _M_curr_symbol_size;
      const _CharT*			_M_positive_sign;
      size_t                            _M_positive_sign_size;
      const _CharT*			_M_negative_sign;
      size_t                            _M_negative_sign_size;
      int				_M_frac_digits;
      money_base::pattern		_M_pos_format;
      money_base::pattern	        _M_neg_format;

      // A list of valid numeric literals for input and output: in the standard
      // "C" locale, this is "-0123456789". This array contains the chars after
      // having been passed through the current locale's ctype<_CharT>.widen().
      _CharT				_M_atoms[money_base::_S_end];

      bool				_M_allocated;

      __moneypunct_cache(size_t __refs = 0) : facet(__refs),
      _M_grouping(NULL), _M_grouping_size(0), _M_use_grouping(false),
      _M_decimal_point(_CharT()), _M_thousands_sep(_CharT()),
      _M_curr_symbol(NULL), _M_curr_symbol_size(0),
      _M_positive_sign(NULL), _M_positive_sign_size(0),
      _M_negative_sign(NULL), _M_negative_sign_size(0),
      _M_frac_digits(0),
      _M_pos_format(money_base::pattern()),
      _M_neg_format(money_base::pattern()), _M_allocated(false)
      { }

      ~__moneypunct_cache();

      void
      _M_cache(const locale& __loc);

    private:
      __moneypunct_cache&
      operator=(const __moneypunct_cache&);
      
      explicit
      __moneypunct_cache(const __moneypunct_cache&);
    };

  template<typename _CharT, bool _Intl>
    __moneypunct_cache<_CharT, _Intl>::~__moneypunct_cache()
    {
      if (_M_allocated)
	{
	  delete [] _M_grouping;
	  delete [] _M_curr_symbol;
	  delete [] _M_positive_sign;
	  delete [] _M_negative_sign;
	}
    }

  /**
   *  @brief  Facet for formatting data for money amounts.
   *
   *  This facet encapsulates the punctuation, grouping and other formatting
   *  features of money amount string representations.
  */
  template<typename _CharT, bool _Intl>
    class moneypunct : public locale::facet, public money_base
    {
    public:
      // Types:
      //@{
      /// Public typedefs
      typedef _CharT			char_type;
      typedef basic_string<_CharT>	string_type;
      //@}
      typedef __moneypunct_cache<_CharT, _Intl>     __cache_type;

    private:
      __cache_type*			_M_data;

    public:
      /// This value is provided by the standard, but no reason for its
      /// existence.
      static const bool			intl = _Intl;
      /// Numpunct facet id.
      static locale::id			id;

      /**
       *  @brief  Constructor performs initialization.
       *
       *  This is the constructor provided by the standard.
       *
       *  @param refs  Passed to the base facet class.
      */
      explicit
      moneypunct(size_t __refs = 0) : facet(__refs), _M_data(NULL)
      { _M_initialize_moneypunct(); }

      /**
       *  @brief  Constructor performs initialization.
       *
       *  This is an internal constructor.
       *
       *  @param cache  Cache for optimization.
       *  @param refs  Passed to the base facet class.
      */
      explicit
      moneypunct(__cache_type* __cache, size_t __refs = 0)
      : facet(__refs), _M_data(__cache)
      { _M_initialize_moneypunct(); }

      /**
       *  @brief  Internal constructor. Not for general use.
       *
       *  This is a constructor for use by the library itself to set up new
       *  locales.
       *
       *  @param cloc  The "C" locale.
       *  @param s  The name of a locale.
       *  @param refs  Passed to the base facet class.
      */
      explicit
      moneypunct(__c_locale __cloc, const char* __s, size_t __refs = 0)
      : facet(__refs), _M_data(NULL)
      { _M_initialize_moneypunct(__cloc, __s); }

      /**
       *  @brief  Return decimal point character.
       *
       *  This function returns a char_type to use as a decimal point.  It
       *  does so by returning returning
       *  moneypunct<char_type>::do_decimal_point().
       *
       *  @return  @a char_type representing a decimal point.
      */
      char_type
      decimal_point() const
      { return this->do_decimal_point(); }

      /**
       *  @brief  Return thousands separator character.
       *
       *  This function returns a char_type to use as a thousands
       *  separator.  It does so by returning returning
       *  moneypunct<char_type>::do_thousands_sep().
       *
       *  @return  char_type representing a thousands separator.
      */
      char_type
      thousands_sep() const
      { return this->do_thousands_sep(); }

      /**
       *  @brief  Return grouping specification.
       *
       *  This function returns a string representing groupings for the
       *  integer part of an amount.  Groupings indicate where thousands
       *  separators should be inserted.
       *
       *  Each char in the return string is interpret as an integer rather
       *  than a character.  These numbers represent the number of digits in a
       *  group.  The first char in the string represents the number of digits
       *  in the least significant group.  If a char is negative, it indicates
       *  an unlimited number of digits for the group.  If more chars from the
       *  string are required to group a number, the last char is used
       *  repeatedly.
       *
       *  For example, if the grouping() returns "\003\002" and is applied to
       *  the number 123456789, this corresponds to 12,34,56,789.  Note that
       *  if the string was "32", this would put more than 50 digits into the
       *  least significant group if the character set is ASCII.
       *
       *  The string is returned by calling
       *  moneypunct<char_type>::do_grouping().
       *
       *  @return  string representing grouping specification.
      */
      string
      grouping() const
      { return this->do_grouping(); }

      /**
       *  @brief  Return currency symbol string.
       *
       *  This function returns a string_type to use as a currency symbol.  It
       *  does so by returning returning
       *  moneypunct<char_type>::do_curr_symbol().
       *
       *  @return  @a string_type representing a currency symbol.
      */
      string_type
      curr_symbol() const
      { return this->do_curr_symbol(); }

      /**
       *  @brief  Return positive sign string.
       *
       *  This function returns a string_type to use as a sign for positive
       *  amounts.  It does so by returning returning
       *  moneypunct<char_type>::do_positive_sign().
       *
       *  If the return value contains more than one character, the first
       *  character appears in the position indicated by pos_format() and the
       *  remainder appear at the end of the formatted string.
       *
       *  @return  @a string_type representing a positive sign.
      */
      string_type
      positive_sign() const
      { return this->do_positive_sign(); }

      /**
       *  @brief  Return negative sign string.
       *
       *  This function returns a string_type to use as a sign for negative
       *  amounts.  It does so by returning returning
       *  moneypunct<char_type>::do_negative_sign().
       *
       *  If the return value contains more than one character, the first
       *  character appears in the position indicated by neg_format() and the
       *  remainder appear at the end of the formatted string.
       *
       *  @return  @a string_type representing a negative sign.
      */
      string_type
      negative_sign() const
      { return this->do_negative_sign(); }

      /**
       *  @brief  Return number of digits in fraction.
       *
       *  This function returns the exact number of digits that make up the
       *  fractional part of a money amount.  It does so by returning
       *  returning moneypunct<char_type>::do_frac_digits().
       *
       *  The fractional part of a money amount is optional.  But if it is
       *  present, there must be frac_digits() digits.
       *
       *  @return  Number of digits in amount fraction.
      */
      int
      frac_digits() const
      { return this->do_frac_digits(); }

      //@{
      /**
       *  @brief  Return pattern for money values.
       *
       *  This function returns a pattern describing the formatting of a
       *  positive or negative valued money amount.  It does so by returning
       *  returning moneypunct<char_type>::do_pos_format() or
       *  moneypunct<char_type>::do_neg_format().
       *
       *  The pattern has 4 fields describing the ordering of symbol, sign,
       *  value, and none or space.  There must be one of each in the pattern.
       *  The none and space enums may not appear in the first field and space
       *  may not appear in the final field.
       *
       *  The parts of a money string must appear in the order indicated by
       *  the fields of the pattern.  The symbol field indicates that the
       *  value of curr_symbol() may be present.  The sign field indicates
       *  that the value of positive_sign() or negative_sign() must be
       *  present.  The value field indicates that the absolute value of the
       *  money amount is present.  none indicates 0 or more whitespace
       *  characters, except at the end, where it permits no whitespace.
       *  space indicates that 1 or more whitespace characters must be
       *  present.
       *
       *  For example, for the US locale and pos_format() pattern
       *  {symbol,sign,value,none}, curr_symbol() == '$' positive_sign() ==
       *  '+', and value 10.01, and options set to force the symbol, the
       *  corresponding string is "$+10.01".
       *
       *  @return  Pattern for money values.
      */
      pattern
      pos_format() const
      { return this->do_pos_format(); }

      pattern
      neg_format() const
      { return this->do_neg_format(); }
      //@}

    protected:
      /// Destructor.
      virtual
      ~moneypunct();

      /**
       *  @brief  Return decimal point character.
       *
       *  Returns a char_type to use as a decimal point.  This function is a
       *  hook for derived classes to change the value returned.
       *
       *  @return  @a char_type representing a decimal point.
      */
      virtual char_type
      do_decimal_point() const
      { return _M_data->_M_decimal_point; }

      /**
       *  @brief  Return thousands separator character.
       *
       *  Returns a char_type to use as a thousands separator.  This function
       *  is a hook for derived classes to change the value returned.
       *
       *  @return  @a char_type representing a thousands separator.
      */
      virtual char_type
      do_thousands_sep() const
      { return _M_data->_M_thousands_sep; }

      /**
       *  @brief  Return grouping specification.
       *
       *  Returns a string representing groupings for the integer part of a
       *  number.  This function is a hook for derived classes to change the
       *  value returned.  @see grouping() for details.
       *
       *  @return  String representing grouping specification.
      */
      virtual string
      do_grouping() const
      { return _M_data->_M_grouping; }

      /**
       *  @brief  Return currency symbol string.
       *
       *  This function returns a string_type to use as a currency symbol.
       *  This function is a hook for derived classes to change the value
       *  returned.  @see curr_symbol() for details.
       *
       *  @return  @a string_type representing a currency symbol.
      */
      virtual string_type
      do_curr_symbol()   const
      { return _M_data->_M_curr_symbol; }

      /**
       *  @brief  Return positive sign string.
       *
       *  This function returns a string_type to use as a sign for positive
       *  amounts.  This function is a hook for derived classes to change the
       *  value returned.  @see positive_sign() for details.
       *
       *  @return  @a string_type representing a positive sign.
      */
      virtual string_type
      do_positive_sign() const
      { return _M_data->_M_positive_sign; }

      /**
       *  @brief  Return negative sign string.
       *
       *  This function returns a string_type to use as a sign for negative
       *  amounts.  This function is a hook for derived classes to change the
       *  value returned.  @see negative_sign() for details.
       *
       *  @return  @a string_type representing a negative sign.
      */
      virtual string_type
      do_negative_sign() const
      { return _M_data->_M_negative_sign; }

      /**
       *  @brief  Return number of digits in fraction.
       *
       *  This function returns the exact number of digits that make up the
       *  fractional part of a money amount.  This function is a hook for
       *  derived classes to change the value returned.  @see frac_digits()
       *  for details.
       *
       *  @return  Number of digits in amount fraction.
      */
      virtual int
      do_frac_digits() const
      { return _M_data->_M_frac_digits; }

      /**
       *  @brief  Return pattern for money values.
       *
       *  This function returns a pattern describing the formatting of a
       *  positive valued money amount.  This function is a hook for derived
       *  classes to change the value returned.  @see pos_format() for
       *  details.
       *
       *  @return  Pattern for money values.
      */
      virtual pattern
      do_pos_format() const
      { return _M_data->_M_pos_format; }

      /**
       *  @brief  Return pattern for money values.
       *
       *  This function returns a pattern describing the formatting of a
       *  negative valued money amount.  This function is a hook for derived
       *  classes to change the value returned.  @see neg_format() for
       *  details.
       *
       *  @return  Pattern for money values.
      */
      virtual pattern
      do_neg_format() const
      { return _M_data->_M_neg_format; }

      // For use at construction time only.
       void
       _M_initialize_moneypunct(__c_locale __cloc = NULL,
				const char* __name = NULL);
    };

  template<typename _CharT, bool _Intl>
    locale::id moneypunct<_CharT, _Intl>::id;

  template<typename _CharT, bool _Intl>
    const bool moneypunct<_CharT, _Intl>::intl;

  template<>
    moneypunct<char, true>::~moneypunct();

  template<>
    moneypunct<char, false>::~moneypunct();

  template<>
    void
    moneypunct<char, true>::_M_initialize_moneypunct(__c_locale, const char*);

  template<>
    void
    moneypunct<char, false>::_M_initialize_moneypunct(__c_locale, const char*);

#ifdef _GLIBCXX_USE_WCHAR_T
  template<>
    moneypunct<wchar_t, true>::~moneypunct();

  template<>
    moneypunct<wchar_t, false>::~moneypunct();

  template<>
    void
    moneypunct<wchar_t, true>::_M_initialize_moneypunct(__c_locale,
							const char*);

  template<>
    void
    moneypunct<wchar_t, false>::_M_initialize_moneypunct(__c_locale,
							 const char*);
#endif

  template<typename _CharT, bool _Intl>
    class moneypunct_byname : public moneypunct<_CharT, _Intl>
    {
    public:
      typedef _CharT			char_type;
      typedef basic_string<_CharT>	string_type;

      static const bool intl = _Intl;

      explicit
      moneypunct_byname(const char* __s, size_t __refs = 0)
      : moneypunct<_CharT, _Intl>(__refs)
      {
	if (std::strcmp(__s, "C") != 0 && std::strcmp(__s, "POSIX") != 0)
	  {
	    __c_locale __tmp;
	    this->_S_create_c_locale(__tmp, __s);
	    this->_M_initialize_moneypunct(__tmp);
	    this->_S_destroy_c_locale(__tmp);
	  }
      }

    protected:
      virtual
      ~moneypunct_byname() { }
    };

  template<typename _CharT, bool _Intl>
    const bool moneypunct_byname<_CharT, _Intl>::intl;

  /**
   *  @brief  Facet for parsing monetary amounts.
   *
   *  This facet encapsulates the code to parse and return a monetary
   *  amount from a string.
   *
   *  The money_get template uses protected virtual functions to
   *  provide the actual results.  The public accessors forward the
   *  call to the virtual functions.  These virtual functions are
   *  hooks for developers to implement the behavior they require from
   *  the money_get facet.
  */
  template<typename _CharT, typename _InIter>
    class money_get : public locale::facet
    {
    public:
      // Types:
      //@{
      /// Public typedefs
      typedef _CharT			char_type;
      typedef _InIter			iter_type;
      typedef basic_string<_CharT>	string_type;
      //@}

      /// Numpunct facet id.
      static locale::id			id;

      /**
       *  @brief  Constructor performs initialization.
       *
       *  This is the constructor provided by the standard.
       *
       *  @param refs  Passed to the base facet class.
      */
      explicit
      money_get(size_t __refs = 0) : facet(__refs) { }

      /**
       *  @brief  Read and parse a monetary value.
       *
       *  This function reads characters from @a s, interprets them as a
       *  monetary value according to moneypunct and ctype facets retrieved
       *  from io.getloc(), and returns the result in @a units as an integral
       *  value moneypunct::frac_digits() * the actual amount.  For example,
       *  the string $10.01 in a US locale would store 1001 in @a units.
       *
       *  Any characters not part of a valid money amount are not consumed.
       *
       *  If a money value cannot be parsed from the input stream, sets
       *  err=(err|io.failbit).  If the stream is consumed before finishing
       *  parsing,  sets err=(err|io.failbit|io.eofbit).  @a units is
       *  unchanged if parsing fails.
       *
       *  This function works by returning the result of do_get().
       *
       *  @param  s  Start of characters to parse.
       *  @param  end  End of characters to parse.
       *  @param  intl  Parameter to use_facet<moneypunct<CharT,intl> >.
       *  @param  io  Source of facets and io state.
       *  @param  err  Error field to set if parsing fails.
       *  @param  units  Place to store result of parsing.
       *  @return  Iterator referencing first character beyond valid money
       *	   amount.
       */
      iter_type
      get(iter_type __s, iter_type __end, bool __intl, ios_base& __io,
	  ios_base::iostate& __err, long double& __units) const
      { return this->do_get(__s, __end, __intl, __io, __err, __units); }

      /**
       *  @brief  Read and parse a monetary value.
       *
       *  This function reads characters from @a s, interprets them as a
       *  monetary value according to moneypunct and ctype facets retrieved
       *  from io.getloc(), and returns the result in @a digits.  For example,
       *  the string $10.01 in a US locale would store "1001" in @a digits.
       *
       *  Any characters not part of a valid money amount are not consumed.
       *
       *  If a money value cannot be parsed from the input stream, sets
       *  err=(err|io.failbit).  If the stream is consumed before finishing
       *  parsing,  sets err=(err|io.failbit|io.eofbit).
       *
       *  This function works by returning the result of do_get().
       *
       *  @param  s  Start of characters to parse.
       *  @param  end  End of characters to parse.
       *  @param  intl  Parameter to use_facet<moneypunct<CharT,intl> >.
       *  @param  io  Source of facets and io state.
       *  @param  err  Error field to set if parsing fails.
       *  @param  digits  Place to store result of parsing.
       *  @return  Iterator referencing first character beyond valid money
       *	   amount.
       */
      iter_type
      get(iter_type __s, iter_type __end, bool __intl, ios_base& __io,
	  ios_base::iostate& __err, string_type& __digits) const
      { return this->do_get(__s, __end, __intl, __io, __err, __digits); }

    protected:
      /// Destructor.
      virtual
      ~money_get() { }

      /**
       *  @brief  Read and parse a monetary value.
       *
       *  This function reads and parses characters representing a monetary
       *  value.  This function is a hook for derived classes to change the
       *  value returned.  @see get() for details.
       */
      virtual iter_type
      do_get(iter_type __s, iter_type __end, bool __intl, ios_base& __io,
	     ios_base::iostate& __err, long double& __units) const;

      /**
       *  @brief  Read and parse a monetary value.
       *
       *  This function reads and parses characters representing a monetary
       *  value.  This function is a hook for derived classes to change the
       *  value returned.  @see get() for details.
       */
      virtual iter_type
      do_get(iter_type __s, iter_type __end, bool __intl, ios_base& __io,
	     ios_base::iostate& __err, string_type& __digits) const;

      template<bool _Intl>
        iter_type
        _M_extract(iter_type __s, iter_type __end, ios_base& __io,
		   ios_base::iostate& __err, string& __digits) const;     
    };

  template<typename _CharT, typename _InIter>
    locale::id money_get<_CharT, _InIter>::id;

  /**
   *  @brief  Facet for outputting monetary amounts.
   *
   *  This facet encapsulates the code to format and output a monetary
   *  amount.
   *
   *  The money_put template uses protected virtual functions to
   *  provide the actual results.  The public accessors forward the
   *  call to the virtual functions.  These virtual functions are
   *  hooks for developers to implement the behavior they require from
   *  the money_put facet.
  */
  template<typename _CharT, typename _OutIter>
    class money_put : public locale::facet
    {
    public:
      //@{
      /// Public typedefs
      typedef _CharT			char_type;
      typedef _OutIter			iter_type;
      typedef basic_string<_CharT>	string_type;
      //@}

      /// Numpunct facet id.
      static locale::id			id;

      /**
       *  @brief  Constructor performs initialization.
       *
       *  This is the constructor provided by the standard.
       *
       *  @param refs  Passed to the base facet class.
      */
      explicit
      money_put(size_t __refs = 0) : facet(__refs) { }

      /**
       *  @brief  Format and output a monetary value.
       *
       *  This function formats @a units as a monetary value according to
       *  moneypunct and ctype facets retrieved from io.getloc(), and writes
       *  the resulting characters to @a s.  For example, the value 1001 in a
       *  US locale would write "$10.01" to @a s.
       *
       *  This function works by returning the result of do_put().
       *
       *  @param  s  The stream to write to.
       *  @param  intl  Parameter to use_facet<moneypunct<CharT,intl> >.
       *  @param  io  Source of facets and io state.
       *  @param  fill  char_type to use for padding.
       *  @param  units  Place to store result of parsing.
       *  @return  Iterator after writing.
       */
      iter_type
      put(iter_type __s, bool __intl, ios_base& __io,
	  char_type __fill, long double __units) const
      { return this->do_put(__s, __intl, __io, __fill, __units); }

      /**
       *  @brief  Format and output a monetary value.
       *
       *  This function formats @a digits as a monetary value according to
       *  moneypunct and ctype facets retrieved from io.getloc(), and writes
       *  the resulting characters to @a s.  For example, the string "1001" in
       *  a US locale would write "$10.01" to @a s.
       *
       *  This function works by returning the result of do_put().
       *
       *  @param  s  The stream to write to.
       *  @param  intl  Parameter to use_facet<moneypunct<CharT,intl> >.
       *  @param  io  Source of facets and io state.
       *  @param  fill  char_type to use for padding.
       *  @param  units  Place to store result of parsing.
       *  @return  Iterator after writing.
       */
      iter_type
      put(iter_type __s, bool __intl, ios_base& __io,
	  char_type __fill, const string_type& __digits) const
      { return this->do_put(__s, __intl, __io, __fill, __digits); }

    protected:
      /// Destructor.
      virtual
      ~money_put() { }

      /**
       *  @brief  Format and output a monetary value.
       *
       *  This function formats @a units as a monetary value according to
       *  moneypunct and ctype facets retrieved from io.getloc(), and writes
       *  the resulting characters to @a s.  For example, the value 1001 in a
       *  US locale would write "$10.01" to @a s.
       *
       *  This function is a hook for derived classes to change the value
       *  returned.  @see put().
       *
       *  @param  s  The stream to write to.
       *  @param  intl  Parameter to use_facet<moneypunct<CharT,intl> >.
       *  @param  io  Source of facets and io state.
       *  @param  fill  char_type to use for padding.
       *  @param  units  Place to store result of parsing.
       *  @return  Iterator after writing.
       */
      virtual iter_type
      do_put(iter_type __s, bool __intl, ios_base& __io, char_type __fill,
	     long double __units) const;

      /**
       *  @brief  Format and output a monetary value.
       *
       *  This function formats @a digits as a monetary value according to
       *  moneypunct and ctype facets retrieved from io.getloc(), and writes
       *  the resulting characters to @a s.  For example, the string "1001" in
       *  a US locale would write "$10.01" to @a s.
       *
       *  This function is a hook for derived classes to change the value
       *  returned.  @see put().
       *
       *  @param  s  The stream to write to.
       *  @param  intl  Parameter to use_facet<moneypunct<CharT,intl> >.
       *  @param  io  Source of facets and io state.
       *  @param  fill  char_type to use for padding.
       *  @param  units  Place to store result of parsing.
       *  @return  Iterator after writing.
       */
      virtual iter_type
      do_put(iter_type __s, bool __intl, ios_base& __io, char_type __fill,
	     const string_type& __digits) const;

      template<bool _Intl>
        iter_type
        _M_insert(iter_type __s, ios_base& __io, char_type __fill,
		  const string_type& __digits) const;
    };

  template<typename _CharT, typename _OutIter>
    locale::id money_put<_CharT, _OutIter>::id;

  /**
   *  @brief  Messages facet base class providing catalog typedef.
   */
  struct messages_base
  {
    typedef int catalog;
  };

  /**
   *  @brief  Facet for handling message catalogs
   *
   *  This facet encapsulates the code to retrieve messages from
   *  message catalogs.  The only thing defined by the standard for this facet
   *  is the interface.  All underlying functionality is
   *  implementation-defined.
   *
   *  This library currently implements 3 versions of the message facet.  The
   *  first version (gnu) is a wrapper around gettext, provided by libintl.
   *  The second version (ieee) is a wrapper around catgets.  The final
   *  version (default) does no actual translation.  These implementations are
   *  only provided for char and wchar_t instantiations.
   *
   *  The messages template uses protected virtual functions to
   *  provide the actual results.  The public accessors forward the
   *  call to the virtual functions.  These virtual functions are
   *  hooks for developers to implement the behavior they require from
   *  the messages facet.
  */
  template<typename _CharT>
    class messages : public locale::facet, public messages_base
    {
    public:
      // Types:
      //@{
      /// Public typedefs
      typedef _CharT			char_type;
      typedef basic_string<_CharT>	string_type;
      //@}

    protected:
      // Underlying "C" library locale information saved from
      // initialization, needed by messages_byname as well.
      __c_locale			_M_c_locale_messages;
      const char*			_M_name_messages;

    public:
      /// Numpunct facet id.
      static locale::id			id;

      /**
       *  @brief  Constructor performs initialization.
       *
       *  This is the constructor provided by the standard.
       *
       *  @param refs  Passed to the base facet class.
      */
      explicit
      messages(size_t __refs = 0);

      // Non-standard.
      /**
       *  @brief  Internal constructor.  Not for general use.
       *
       *  This is a constructor for use by the library itself to set up new
       *  locales.
       *
       *  @param  cloc  The "C" locale.
       *  @param  s  The name of a locale.
       *  @param  refs  Refcount to pass to the base class.
       */
      explicit
      messages(__c_locale __cloc, const char* __s, size_t __refs = 0);

      /*
       *  @brief  Open a message catalog.
       *
       *  This function opens and returns a handle to a message catalog by
       *  returning do_open(s, loc).
       *
       *  @param  s  The catalog to open.
       *  @param  loc  Locale to use for character set conversions.
       *  @return  Handle to the catalog or value < 0 if open fails.
      */
      catalog
      open(const basic_string<char>& __s, const locale& __loc) const
      { return this->do_open(__s, __loc); }

      // Non-standard and unorthodox, yet effective.
      /*
       *  @brief  Open a message catalog.
       *
       *  This non-standard function opens and returns a handle to a message
       *  catalog by returning do_open(s, loc).  The third argument provides a
       *  message catalog root directory for gnu gettext and is ignored
       *  otherwise.
       *
       *  @param  s  The catalog to open.
       *  @param  loc  Locale to use for character set conversions.
       *  @param  dir  Message catalog root directory.
       *  @return  Handle to the catalog or value < 0 if open fails.
      */
      catalog
      open(const basic_string<char>&, const locale&, const char*) const;

      /*
       *  @brief  Look up a string in a message catalog.
       *
       *  This function retrieves and returns a message from a catalog by
       *  returning do_get(c, set, msgid, s).
       *
       *  For gnu, @a set and @a msgid are ignored.  Returns gettext(s).
       *  For default, returns s. For ieee, returns catgets(c,set,msgid,s).
       *
       *  @param  c  The catalog to access.
       *  @param  set  Implementation-defined.
       *  @param  msgid  Implementation-defined.
       *  @param  s  Default return value if retrieval fails.
       *  @return  Retrieved message or @a s if get fails.
      */
      string_type
      get(catalog __c, int __set, int __msgid, const string_type& __s) const
      { return this->do_get(__c, __set, __msgid, __s); }

      /*
       *  @brief  Close a message catalog.
       *
       *  Closes catalog @a c by calling do_close(c).
       *
       *  @param  c  The catalog to close.
      */
      void
      close(catalog __c) const
      { return this->do_close(__c); }

    protected:
      /// Destructor.
      virtual
      ~messages();

      /*
       *  @brief  Open a message catalog.
       *
       *  This function opens and returns a handle to a message catalog in an
       *  implementation-defined manner.  This function is a hook for derived
       *  classes to change the value returned.
       *
       *  @param  s  The catalog to open.
       *  @param  loc  Locale to use for character set conversions.
       *  @return  Handle to the opened catalog, value < 0 if open failed.
      */
      virtual catalog
      do_open(const basic_string<char>&, const locale&) const;

      /*
       *  @brief  Look up a string in a message catalog.
       *
       *  This function retrieves and returns a message from a catalog in an
       *  implementation-defined manner.  This function is a hook for derived
       *  classes to change the value returned.
       *
       *  For gnu, @a set and @a msgid are ignored.  Returns gettext(s).
       *  For default, returns s. For ieee, returns catgets(c,set,msgid,s).
       *
       *  @param  c  The catalog to access.
       *  @param  set  Implementation-defined.
       *  @param  msgid  Implementation-defined.
       *  @param  s  Default return value if retrieval fails.
       *  @return  Retrieved message or @a s if get fails.
      */
      virtual string_type
      do_get(catalog, int, int, const string_type& __dfault) const;

      /*
       *  @brief  Close a message catalog.
       *
       *  @param  c  The catalog to close.
      */
      virtual void
      do_close(catalog) const;

      // Returns a locale and codeset-converted string, given a char* message.
      char*
      _M_convert_to_char(const string_type& __msg) const
      {
	// XXX
	return reinterpret_cast<char*>(const_cast<_CharT*>(__msg.c_str()));
      }

      // Returns a locale and codeset-converted string, given a char* message.
      string_type
      _M_convert_from_char(char*) const
      {
#if 0
	// Length of message string without terminating null.
	size_t __len = char_traits<char>::length(__msg) - 1;

	// "everybody can easily convert the string using
	// mbsrtowcs/wcsrtombs or with iconv()"

	// Convert char* to _CharT in locale used to open catalog.
	// XXX need additional template parameter on messages class for this..
	// typedef typename codecvt<char, _CharT, _StateT> __codecvt_type;
	typedef typename codecvt<char, _CharT, mbstate_t> __codecvt_type;

	__codecvt_type::state_type __state;
	// XXX may need to initialize state.
	//initialize_state(__state._M_init());

	char* __from_next;
	// XXX what size for this string?
	_CharT* __to = static_cast<_CharT*>(__builtin_alloca(__len + 1));
	const __codecvt_type& __cvt = use_facet<__codecvt_type>(_M_locale_conv);
	__cvt.out(__state, __msg, __msg + __len, __from_next,
		  __to, __to + __len + 1, __to_next);
	return string_type(__to);
#endif
#if 0
	typedef ctype<_CharT> __ctype_type;
	// const __ctype_type& __cvt = use_facet<__ctype_type>(_M_locale_msg);
	const __ctype_type& __cvt = use_facet<__ctype_type>(locale());
	// XXX Again, proper length of converted string an issue here.
	// For now, assume the converted length is not larger.
	_CharT* __dest = static_cast<_CharT*>(__builtin_alloca(__len + 1));
	__cvt.widen(__msg, __msg + __len, __dest);
	return basic_string<_CharT>(__dest);
#endif
	return string_type();
      }
     };

  template<typename _CharT>
    locale::id messages<_CharT>::id;

  // Specializations for required instantiations.
  template<>
    string
    messages<char>::do_get(catalog, int, int, const string&) const;

#ifdef _GLIBCXX_USE_WCHAR_T
  template<>
    wstring
    messages<wchar_t>::do_get(catalog, int, int, const wstring&) const;
#endif

  template<typename _CharT>
    class messages_byname : public messages<_CharT>
    {
    public:
      typedef _CharT			char_type;
      typedef basic_string<_CharT>	string_type;

      explicit
      messages_byname(const char* __s, size_t __refs = 0);

    protected:
      virtual
      ~messages_byname()
      { }
    };

  // Include host and configuration specific messages functions.
  #include <bits/messages_members.h>


  // Subclause convenience interfaces, inlines.
  // NB: These are inline because, when used in a loop, some compilers
  // can hoist the body out of the loop; then it's just as fast as the
  // C is*() function.
  //@{
  /// Convenience interface to ctype.is().
  template<typename _CharT>
    inline bool
    isspace(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).is(ctype_base::space, __c); }

  template<typename _CharT>
    inline bool
    isprint(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).is(ctype_base::print, __c); }

  template<typename _CharT>
    inline bool
    iscntrl(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).is(ctype_base::cntrl, __c); }

  template<typename _CharT>
    inline bool
    isupper(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).is(ctype_base::upper, __c); }

  template<typename _CharT>
    inline bool islower(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).is(ctype_base::lower, __c); }

  template<typename _CharT>
    inline bool
    isalpha(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).is(ctype_base::alpha, __c); }

  template<typename _CharT>
    inline bool
    isdigit(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).is(ctype_base::digit, __c); }

  template<typename _CharT>
    inline bool
    ispunct(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).is(ctype_base::punct, __c); }

  template<typename _CharT>
    inline bool
    isxdigit(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).is(ctype_base::xdigit, __c); }

  template<typename _CharT>
    inline bool
    isalnum(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).is(ctype_base::alnum, __c); }

  template<typename _CharT>
    inline bool
    isgraph(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).is(ctype_base::graph, __c); }

  template<typename _CharT>
    inline _CharT
    toupper(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).toupper(__c); }

  template<typename _CharT>
    inline _CharT
    tolower(_CharT __c, const locale& __loc)
    { return use_facet<ctype<_CharT> >(__loc).tolower(__c); }
  //@}
} // namespace std

#endif

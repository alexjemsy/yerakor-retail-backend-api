// see: https://shopify.dev/docs/api/usage/search-syntax

interface Comparator {
  isGreaterThanOrEqualTo: boolean;
  isLessThanOrEqualTo: boolean;
  isGreaterThan: boolean;
  isLessThan: boolean;
  isEqualTo: boolean;
}

interface Term {
  name?: string;
  comparator?: Comparator;
  value?: string;
  isNegate: boolean;
  query?: ShopifyParsedSearchQuery;
}

interface Connective {
  isAnd: boolean;
  isOr: boolean;
}

export interface ShopifyParsedSearchQuery {
  terms: Term[];
  connectives: Connective[];
}

interface Context {
  text: string;
  startIndex: number;
}

export const shopifySearchQueryParser = (queryString: string) => {
  const context: Context = {
    text: queryString.trim(),
    startIndex: 0,
  };

  return parseQuery(context);
};

const quoteCharacters = ["'", '"'];

const parseQuery = (context: Context) => {
  const terms: Term[] = [];
  const connectives: Connective[] = [];

  const query = {
    terms,
    connectives,
  };

  const mergeTermsIfPossible = () => {
    const values = [];
    const [firstTerm] = terms;

    if (!firstTerm || terms.length < 2 || connectives.length) return;

    for (const term of terms) {
      if (term.query) return;

      if (term.name && values.length) return;

      values.push(term.value);
    }

    query.terms = [firstTerm];
    firstTerm.value = values.join(' ');
  };

  while (context.text.length && context.startIndex < context.text.length) {
    if (isWhiteSpace(context.text[context.startIndex]!)) {
      context.startIndex += 1;
      continue;
    }

    terms.push(parseTerm(context));

    if (context.startIndex >= context.text.length) break;

    const connective = {
      isAnd: false,
      isOr: false,
    };

    if (
      context.text.substring(context.startIndex, context.startIndex + 5) ===
      ' AND '
    ) {
      connective.isAnd = true;
      context.startIndex += 5;
      connectives.push(connective);
      continue;
    }

    if (
      context.text.substring(context.startIndex, context.startIndex + 4) ===
      ' OR '
    ) {
      connective.isOr = true;
      context.startIndex += 4;
      connectives.push(connective);
      continue;
    }

    if (!isWhiteSpace(context.text[context.startIndex]!)) break;

    connective.isAnd = true;
    context.startIndex += 1;
    connectives.push(connective);
  }

  mergeTermsIfPossible();
  return query;
};

const getComparator = (context: Context) => {
  if (context.text[context.startIndex] !== ':') return null;

  const comparator: Comparator = {
    isGreaterThanOrEqualTo: false,
    isLessThanOrEqualTo: false,
    isGreaterThan: false,
    isLessThan: false,
    isEqualTo: false,
  };

  if (context.text[context.startIndex + 1] === '<') {
    if (context.text[context.startIndex + 2] === '=') {
      comparator.isLessThanOrEqualTo = true;
      context.startIndex += 3;
      return comparator;
    }

    comparator.isLessThan = true;
    context.startIndex += 2;
    return comparator;
  }

  if (context.text[context.startIndex + 1] === '>') {
    if (context.text[context.startIndex + 2] === '=') {
      comparator.isGreaterThanOrEqualTo = true;
      context.startIndex += 3;
      return comparator;
    }

    comparator.isGreaterThan = true;
    context.startIndex += 2;
    return comparator;
  }

  context.startIndex += 1;
  comparator.isEqualTo = true;

  return comparator;
};

const isWhiteSpace = (char: string) => {
  return [' ', '\t', '\n'].includes(char);
};

const parseNameOrValue = (context: Context) => {
  const { text } = context;
  const firstCharacter = text[context.startIndex];
  const isQuoted = firstCharacter
    ? quoteCharacters.includes(firstCharacter)
    : false;
  const textArray = [];
  const specialCharacters = [':', '(', ')', '\\'];
  let isValidName = true;

  if (isQuoted) {
    context.startIndex += 1;
    isValidName = false;
  }

  while (context.startIndex < text.length) {
    if (!isQuoted && text[context.startIndex] === '\\') {
      context.startIndex += 1;

      if (!specialCharacters.includes(text[context.startIndex]!)) {
        throw new Error('Backslash character must be escaped with a backslash');
      }

      textArray.push(text[context.startIndex]);
      context.startIndex += 1;
      continue;
    }

    if (
      !isQuoted &&
      (specialCharacters.includes(text[context.startIndex]!) ||
        isWhiteSpace(text[context.startIndex]!))
    ) {
      break;
    }

    if (isQuoted && quoteCharacters.includes(text[context.startIndex]!)) {
      if (firstCharacter === text[context.startIndex]) {
        context.startIndex += 1;

        return {
          isValidName: false,
          text: textArray.join(''),
        };
      }

      throw new Error(
        'Quoted string should have the same quote character on both ends',
      );
    }

    textArray.push(text[context.startIndex]);
    context.startIndex += 1;
  }

  if (!isQuoted) {
    return {
      isValidName,
      text: textArray.join(''),
    };
  }

  throw new Error('Quoted string should have a quote character at the end');
};

const parseTerm = (context: Context): Term => {
  let isNegate = false;

  if (context.text[context.startIndex] === '-') {
    context.startIndex += 1;
    isNegate = true;
  } else if (
    context.text.substring(context.startIndex, context.startIndex + 4) ===
    'NOT '
  ) {
    context.startIndex += 4;
    isNegate = true;
  }

  if (context.text[context.startIndex] === '(') {
    context.startIndex += 1;
    const query = parseQuery(context);

    if (context.text[context.startIndex] !== ')')
      throw new Error('Grouped terms must be closed with )');

    context.startIndex += 1;

    return {
      isNegate,
      query,
    };
  }

  const initialStartIndex = context.startIndex;
  const { isValidName, text } = parseNameOrValue(context);

  if (context.startIndex === initialStartIndex) {
    throw new Error('Unable to parse name or value');
  }

  if (isValidName && context.startIndex < context.text.length) {
    const comparator = getComparator(context);

    if (comparator) {
      return {
        isNegate,
        name: text,
        comparator,
        value: parseNameOrValue(context).text,
      };
    }
  }

  return {
    isNegate,
    value: text,
  };
};

from urllib.parse import urlparse


SHORTENERS = {
    'bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'ow.ly', 'is.gd',
    'buff.ly', 'cutt.ly', 'rebrand.ly', 'shorturl.at'
}


def analyze_url(url: str) -> dict:
    raw = url.strip()
    parsed = urlparse(raw)
    valid = parsed.scheme in {'http', 'https'} and bool(parsed.netloc)
    host = (parsed.hostname or '').lower()
    is_https = parsed.scheme == 'https'
    is_long = len(raw) > 40
    is_shortener = host in SHORTENERS or any(host.endswith('.' + domain) for domain in SHORTENERS)

    indicators = []
    if not valid:
        indicators.append('URL format could not be validated')
    else:
        indicators.append(f'Host: {host}')
        if not is_https:
            indicators.append('HTTP URL: encrypted transport is not indicated')
        if is_long:
            indicators.append('Long URL detected')
        if is_shortener:
            indicators.append('Known URL shortener detected')
        if parsed.username:
            indicators.append('URL contains embedded user information before the host')
        if parsed.port:
            indicators.append(f'Non-default port detected: {parsed.port}')

    return {
        'url': raw,
        'valid': valid,
        'https': is_https,
        'long_url': is_long,
        'shortener': is_shortener,
        'host': host,
        'indicators': indicators,
    }

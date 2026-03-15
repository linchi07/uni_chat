export const onRequest: PagesFunction = async ({ request, next }) => {
    const url = new URL(request.url);

    // 只在根路径进行重定向，避免干扰用户的手动语言选择
    if (url.pathname === '/') {
        const acceptLanguage = request.headers.get('Accept-Language') || '';

        // 如果浏览器首选语言包含 'zh'（中文），则重定向到中文版
        if (acceptLanguage.toLowerCase().includes('zh')) {
            return Response.redirect(new URL('/zh-Hans/', request.url), 302);
        }
    }

    return next();
};

import { unified } from 'unified';
import rehypeParse from 'rehype-parse';
import rehypeRemark from 'rehype-remark';
import remarkStringify from 'remark-stringify';
import remarkGfm from 'remark-gfm';
import slug from 'rehype-slug';
import rehypeAutolinkHeadings from 'rehype-autolink-headings';
import rehypeIgnore from 'rehype-ignore';
import rehypeRaw from 'rehype-raw';
import rehypeFormat from 'rehype-format';
import rehypePrism from 'rehype-prism-plus';
import rehypeVideo from 'rehype-video';

export default function htmlToMarkdown(htmlStr = '', options = {}) {
  const { 
    enableAutolinkHeadings = false, 
    fragment = true,
    rule = '*' // 控制 <hr> 转换样式: '*', '-', '_'
  } = options;
  
  const processor = unified()
    .use(rehypeParse, { fragment })
    .use(slug);
  
  if (enableAutolinkHeadings) {
    processor.use(rehypeAutolinkHeadings);
  }
  
  const file = processor
    .use(rehypeIgnore)
    .use(rehypeVideo)
    .use(rehypeFormat)
    .use(rehypeRaw)
    .use(rehypePrism)
    .use(rehypeRemark)
    .use(remarkGfm)
    .use(remarkStringify, {
      rule: rule // 设置水平分割线样式
    })
    .processSync(htmlStr);
  return String(file);
}
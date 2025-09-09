import Testing
@testable import HTMLToMarkdown

@Test func example() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <h2>Web tool</h2>
    <p>Hello World</p>
    <pre><code class="language-css">body { color: 'red'; }
    </code></pre>
    """
    /// 预期结果
    let expected = """
    ## Web tool

    Hello World

    ```css
    body { color: 'red'; }
    ```
    """
    let markdown = try toMarkdown.conversion(html)
    #expect(markdown.trimmingCharacters(in: .whitespacesAndNewlines) == expected)
}

@Test func testTable() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Age</th>
          <th>City</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>John</td>
          <td>25</td>
          <td>New York</td>
        </tr>
        <tr>
          <td>Jane</td>
          <td>30</td>
          <td>London</td>
        </tr>
      </tbody>
    </table>
    """
    /// 预期结果
    let expected = """
    | Name | Age | City     |
    | ---- | --- | -------- |
    | John | 25  | New York |
    | Jane | 30  | London   |
    """
    
    let markdown = try toMarkdown.conversion(html)
    #expect(expected == markdown.trimmingCharacters(in: .whitespacesAndNewlines))
    
    // 验证包含表格标记
    #expect(markdown.contains("|"))
    #expect(markdown.contains("Name"))
    #expect(markdown.contains("Age"))
    #expect(markdown.contains("City"))
    #expect(markdown.contains("John"))
    #expect(markdown.contains("Jane"))
}

@Test func testUnorderedList() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <ul>
      <li>First item</li>
      <li>Second item</li>
      <li>Third item with <strong>bold text</strong></li>
    </ul>
    """
    
    let expected = """
    * First item
    * Second item
    * Third item with **bold text**
    """
    
    let markdown = try toMarkdown.conversion(html)
    #expect(expected == markdown.trimmingCharacters(in: .whitespacesAndNewlines))
}

@Test func testOrderedList() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <ol>
      <li>First step</li>
      <li>Second step</li>
      <li>Third step with <em>italic text</em></li>
    </ol>
    """
    /// 预期结果
    let expected = """
    1. First step
    2. Second step
    3. Third step with *italic text*
    """
    
    let markdown = try toMarkdown.conversion(html)
    #expect(expected == markdown.trimmingCharacters(in: .whitespacesAndNewlines))
    
    // 验证包含编号列表标记
    #expect(markdown.contains("1."))
    #expect(markdown.contains("2."))
    #expect(markdown.contains("3."))
    #expect(markdown.contains("First step"))
    #expect(markdown.contains("Second step"))
    #expect(markdown.contains("Third step"))
}

@Test func testNestedList() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <ul>
      <li>Parent item 1
        <ul>
          <li>Child item 1</li>
          <li>Child item 2</li>
        </ul>
      </li>
      <li>Parent item 2</li>
    </ul>
    """
    /// 预期结果
    let expected = """
    * Parent item 1

      * Child item 1
      * Child item 2

    * Parent item 2
    """
    
    let markdown = try toMarkdown.conversion(html)
    #expect(expected == markdown.trimmingCharacters(in: .whitespacesAndNewlines))
    
    // 验证包含嵌套列表结构
    #expect(markdown.contains("Parent item 1"))
    #expect(markdown.contains("Child item 1"))
    #expect(markdown.contains("Child item 2"))
    #expect(markdown.contains("Parent item 2"))
}

@Test func testTextFormatting() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <p>This is <strong>bold text</strong> and this is <em>italic text</em>.</p>
    <p>Here's some <code>inline code</code> and a <a href="https://example.com">link</a>.</p>
    <blockquote>
      <p>This is a blockquote with <strong>bold</strong> text.</p>
    </blockquote>
    """
    /// 预期结果
    let expected = """
    This is **bold text** and this is *italic text*.

    Here's some `inline code` and a [link](https://example.com).

    > This is a blockquote with **bold** text.
    """
    
    let markdown = try toMarkdown.conversion(html)
    #expect(expected == markdown.trimmingCharacters(in: .whitespacesAndNewlines))
    // 验证格式化标记
    #expect(markdown.contains("**bold text**"))
    #expect(markdown.contains("*italic text*"))
    #expect(markdown.contains("`inline code`"))
    #expect(markdown.contains("[link](https://example.com)"))
    #expect(markdown.contains(">"))
}

@Test func testHeadings() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <h1>Heading 1</h1>
    <h2>Heading 2</h2>
    <h3>Heading 3</h3>
    <h4>Heading 4</h4>
    <h5>Heading 5</h5>
    <h6>Heading 6</h6>
    """
    /// 预期结果
    let expected = """
    # Heading 1

    ## Heading 2

    ### Heading 3

    #### Heading 4

    ##### Heading 5

    ###### Heading 6
    """
    
    let markdown = try toMarkdown.conversion(html)
    #expect(expected == markdown.trimmingCharacters(in: .whitespacesAndNewlines))
    // 验证标题标记
    #expect(markdown.contains("# Heading 1"))
    #expect(markdown.contains("## Heading 2"))
    #expect(markdown.contains("### Heading 3"))
    #expect(markdown.contains("#### Heading 4"))
    #expect(markdown.contains("##### Heading 5"))
    #expect(markdown.contains("###### Heading 6"))
}

@Test func testCodeBlocks() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <pre><code>const greeting = "Hello, World!";
    console.log(greeting);</code></pre>
    
    <pre><code class="language-python">def hello():
        print("Hello, Python!")
    hello()</code></pre>
    """
    let expected = """
    ```
    const greeting = "Hello, World!";
    console.log(greeting);
    ```

    ```python
    def hello():
        print("Hello, Python!")
    hello()
    ```
    """
    
    let markdown = try toMarkdown.conversion(html)
    #expect(expected == markdown.trimmingCharacters(in: .whitespacesAndNewlines))
    
    // 验证代码块标记
    #expect(markdown.contains("```"))
    #expect(markdown.contains("const greeting"))
    #expect(markdown.contains("def hello()"))
}

@Test func testImages() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <p>Here's an image:</p>
    <img src="https://example.com/image.jpg" alt="Example Image" title="This is an example">
    <p>And another one without title:</p>
    <img src="https://example.com/photo.png" alt="Photo">
    """
    let expected = """
    Here's an image:

    ![Example Image](https://example.com/image.jpg "This is an example")

    And another one without title:

    ![Photo](https://example.com/photo.png)
    """
    
    let markdown = try toMarkdown.conversion(html)
    #expect(expected == markdown.trimmingCharacters(in: .whitespacesAndNewlines))
    // 验证图片标记
    #expect(markdown.contains("![Example Image](https://example.com/image.jpg"))
    #expect(markdown.contains("![Photo](https://example.com/photo.png)"))
}

@Test func testHorizontalRule() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <p>Content before</p>
    <hr>
    <p>Content after</p>
    """
    let expected = """
    Content before

    ***

    Content after
    """
    
    let markdown = try toMarkdown.conversion(html)
    #expect(expected == markdown.trimmingCharacters(in: .whitespacesAndNewlines))
    
    // 验证水平分割线
    #expect(markdown.contains("***"))
    #expect(markdown.contains("Content before"))
    #expect(markdown.contains("Content after"))
}

@Test func testHorizontalRuleWithDashes() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <p>Content before</p>
    <hr>
    <p>Content after</p>
    """
    let expected = """
    Content before

    ---

    Content after
    """
    
    // 使用 - 样式
    let markdown = try toMarkdown.conversion(html, options: ["rule": "-"])
    #expect(expected == markdown.trimmingCharacters(in: .whitespacesAndNewlines))
    
    // 验证使用了 --- 样式
    #expect(markdown.contains("---"))
    #expect(markdown.contains("Content before"))
    #expect(markdown.contains("Content after"))
}

@Test func testHorizontalRuleWithUnderscores() async throws {
    let toMarkdown = try HTMLToMarkdown()
    let html = """
    <p>Content before</p>
    <hr>
    <p>Content after</p>
    """
    let expected = """
    Content before

    ___

    Content after
    """
    
    // 使用 _ 样式
    let markdown = try toMarkdown.conversion(html, options: ["rule": "_"])
    #expect(expected == markdown.trimmingCharacters(in: .whitespacesAndNewlines))
    
    // 验证使用了 ___ 样式
    #expect(markdown.contains("___"))
    #expect(markdown.contains("Content before"))
    #expect(markdown.contains("Content after"))
}

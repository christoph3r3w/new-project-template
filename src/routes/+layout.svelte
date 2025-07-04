<script>
	let {children} = $props();
	import {Header, Footer} from '$lib';
</script>


<header>
	<Header />
</header>
<main>
	{@render children()}
</main>
<footer>
	<Footer/>
</footer>